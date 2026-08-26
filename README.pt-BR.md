<div align="center">

# tjobs-packs

[English](README.md) · **Português**

[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ianptkcs)

</div>

---

Registry de job packs para o [tjobs](https://github.com/ianptkcs/tabelajobs):
jobs de terminal compartilhaveis que qualquer pessoa instala com um comando,
revisa e so entao ativa.

Um **pack** e um diretorio de job comum do
[tjobs](https://github.com/ianptkcs/tabelajobs#the-job-convention) mais um
manifest `<name>.pack.toml`. Instalar nunca executa nada: pack com schedule
sugerido entra como **timer pausado**, pack sem schedule entra como **job
manual**. Voce le o script primeiro; o schedule so dispara depois que voce
arma (`t` na TUI do tjobs).

## Instalar

```bash
# deste registry (instalacao por subdir)
tjobs install https://github.com/TabelaDev/tjobs-packs#model-monitor

# ou navegue dentro da TUI do tjobs: aperte p

# ou direto de qualquer repo git / caminho local, sem registry
tjobs install /caminho/para/pack-dir
```

Depois revise o script e ative:

| O pack traz              | Entra como   | Como ativar               |
| ------------------------ | ------------ | ------------------------- |
| `schedule` no manifest   | timer pausado | revise, aperte `t`        |
| sem `schedule`           | job manual    | revise, rode com `x`      |

## Packs disponiveis

| Nome            | O que faz                                                                                              | Schedule sugerido |
| --------------- | ------------------------------------------------------------------------------------------------------ | ----------------- |
| `model-monitor` | Vigia precos de LLM via models.dev: alerta gratis→pago, mudanca de preco nos providers da watchlist e modelo novo gratis em qualquer lugar | a cada 6h         |

`tjobs packs list` mostra sempre o conteudo atual do registry.

## Escrever seu proprio pack

```
my-pack/
  my-pack.sh           # o script (convensao de job do tjobs)
  my-pack.pack.toml    # o manifest
```

`my-pack.pack.toml`:

```toml
name = "my-pack"
description = "O que faz, exibido nas listagens"
author = "voce"
source = "https://github.com/TabelaDev/tjobs-packs"  # habilita `tjobs packs update`
schedule = "*-*-* 09:00:00"                          # OnCalendar sugerido (opcional)
```

Recomendacoes:

- Scripts seguem a [convensao de jobs do tjobs](https://github.com/ianptkcs/tabelajobs/blob/main/instructions.md)
  (`set -euo pipefail`, tail de self-cleanup em one-shots, nenhum em recorrentes).
- Jobs que usam rede precisam esperar conectividade antes de qualquer operacao.
- Mantenha os packs flat: script + manifest + notas/sidecars opcionais. Logs
  sao estado de runtime e nunca fazem parte do pack.

## Enviar um pack

1. Adicione `<seu-pack>/` com script e manifest.
2. Adicione a entrada em `index.json`.
3. Abra um PR. Depois do merge, aparece pra todo mundo no `tjobs packs list`
   e no browser da TUI (`p`).

## Licenca

[AGPL-3.0](LICENSE)
