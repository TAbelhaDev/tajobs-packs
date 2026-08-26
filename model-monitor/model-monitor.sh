#!/usr/bin/env bash
# model-monitor: vigia precos de modelos LLM via models.dev e avisa quando
#   1. um modelo que era gratis ($0/$0) passa a cobrar (qualquer provider)
#   2. o preco de qualquer modelo muda nos providers da WATCHLIST
#   3. um modelo da watchlist some do catalogo
#   4. surge um modelo novo gratuito em QUALQUER provider (descoberta)
#
# Estado: compara o catalogo atual contra <dir>/state.json (snapshot da
# rodada anterior). A primeira rodada so semeia o baseline, sem alertas.
#
# Convencao tjobs: job recorrente, timer a cada 6h, sem self-cleanup.
set -euo pipefail

wait_for_net() {
    local tries=${1:-60} # 60 tentativas de 5s = ate 5min
    local i=0
    while [ "$i" -lt "$tries" ]; do
        if curl -fsS --connect-timeout 3 --max-time 5 -o /dev/null https://models.dev 2>/dev/null; then
            return 0
        fi
        i=$((i + 1))
        sleep 5
    done
    echo "Sem conexao com models.dev apos $((tries * 5))s, abortando" >&2
    return 1
}
wait_for_net

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STATE="$DIR/state.json"
# Providers cujas mudancas de preco importam diretamente (sua superficie de uso).
WATCHLIST="opencode opencode-go deepseek"

SNAPSHOT="$(mktemp)"
trap 'rm -f "$SNAPSHOT"' EXIT
curl -fsSL --max-time 90 https://models.dev/api.json -o "$SNAPSHOT"

ALERTS="$(python3 - "$SNAPSHOT" "$STATE" "$WATCHLIST" <<'PYEOF'
import json, os, sys, tempfile, time

api_path, state_path = sys.argv[1], sys.argv[2]
watchlist = sys.argv[3].split()

data = json.load(open(api_path))
models = {}
for pid, prov in data.items():
    for mid, m in (prov.get("models") or {}).items():
        cost = m.get("cost") or {}
        models[f"{pid}/{mid}"] = {
            "i": cost.get("input") or 0,
            "o": cost.get("output") or 0,
            "n": m.get("name") or mid,
        }

old = {}
if os.path.exists(state_path):
    try:
        with open(state_path) as f:
            old = json.load(f).get("models", {})
    except Exception:
        old = {}

wl = tuple(p + "/" for p in watchlist)


def money(v):
    return f"${v:g}/M"


alerts = []
if not old:
    n_free = sum(1 for v in models.values() if v["i"] == 0 and v["o"] == 0)
    alerts.append(f"baseline: monitorando {len(models)} modelos ({n_free} gratuitos)")
else:
    # 1. gratis virou pago em qualquer lugar / 4. novo modelo gratis em qualquer lugar
    for k, v in models.items():
        prev = old.get(k)
        is_free_now = v["i"] == 0 and v["o"] == 0
        if prev is None:
            if is_free_now:
                alerts.append(f"! NOVO GRATIS: {k} ({v['n']})")
            continue
        was_free = prev["i"] == 0 and prev["o"] == 0
        if was_free and not is_free_now and k.startswith(wl):
            alerts.append(
                f"!! GRATIS->PAGO: {k}: era {money(prev['i'])}/{money(prev['o'])}, agora {money(v['i'])}/{money(v['o'])}"
            )

    # 2. mudanca de preco na watchlist
    for k, v in models.items():
        if not k.startswith(wl):
            continue
        prev = old.get(k)
        if prev is None or ((prev["i"] == 0 and prev["o"] == 0) and (v["i"] == 0 and v["o"] == 0)):
            continue
        if (prev["i"], prev["o"]) != (v["i"], v["o"]):
            up = "SOBEU" if (v["i"] > prev["i"] or v["o"] > prev["o"]) else "mudou"
            alerts.append(
                f"! PRECO {up}: {k}: {money(prev['i'])}/{money(prev['o'])} -> {money(v['i'])}/{money(v['o'])}"
            )

    # 3. modelo da watchlist sumiu
    for k in old:
        if k.startswith(wl) and k not in models:
            alerts.append(f"! SUMIU: {k}")

state = {"updated": time.strftime("%Y-%m-%dT%H:%M:%S%z"), "models": models}
fd, tmp = tempfile.mkstemp(dir=os.path.dirname(state_path) or ".", prefix=".state-")
with os.fdopen(fd, "w") as f:
    json.dump(state, f)
os.replace(tmp, state_path)

print("\n".join(alerts))
PYEOF
)"

if [ -n "$ALERTS" ]; then
    echo "[$(date '+%F %T')] model-monitor:"
    echo "$ALERTS"
    if command -v notify-send >/dev/null 2>&1; then
        critical="$(printf '%s\n' "$ALERTS" | grep '^!!' | head -1 || true)"
        normal="$(printf '%s\n' "$ALERTS" | grep -v '^!' | head -1 || true)"
        extra="$(printf '%s\n' "$ALERTS" | tail -n +2 | wc -l)"
        if [ -n "$critical" ]; then
            msg="${critical#! }"
            [ "$extra" -gt 0 ] && msg="$msg (+$extra no log)"
            notify-send -u critical -a tjobs "tjobs model-monitor" "$msg" || true
        elif [ -n "$normal" ] && ! printf '%s\n' "$ALERTS" | grep -q '^baseline:'; then
            msg="${normal#! }"
            [ "$extra" -gt 0 ] && msg="$msg (+$extra no log)"
            notify-send -u normal -a tjobs "tjobs model-monitor" "$msg" || true
        fi
    fi
else
    echo "[$(date '+%F %T')] model-monitor: sem mudancas"
fi
