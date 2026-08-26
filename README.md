# tjobs-packs

Registry de job packs para o [tjobs](https://github.com/ianptkcs/tabelajobs):
jobs compartilhaveis que qualquer pessoa instala com um comando e revisa antes
de ativar.

## Layout

- `index.json` na raiz: o indice que o tjobs consulta (nome, descricao,
  source, subdir, tags, schedule sugerido).
- Um diretorio por pack: `<pack>/<pack>.sh` + `<pack>.pack.toml` (manifest).

## Instalar um pack

```bash
tjobs install https://github.com/TabelaDev/tjobs-packs#model-monitor
```

ou pela TUI do tjobs: `p` abre o browser de packs.

**Nada roda automaticamente.** Pack com `schedule` no manifest entra como
timer pausado; revise o script e ative com `t`. Pack sem schedule entra
manual; rode com `x`.

## Packs disponiveis

- **model-monitor**: vigia precos de LLM via models.dev. Alerta quando um
  modelo gratis vira pago, quando preco muda nos providers da watchlist
  (opencode-go, zen, deepseek) e quando surge modelo novo gratis em
  qualquer provider. Timer sugerido: a cada 6h.

## Enviar um pack

1. Crie `<seu-pack>/<seu-pack>.sh` + `<seu-pack>/<seu-pack>.pack.toml`
   (campos: name, description, author, source, schedule opcional).
2. Adicione a entrada em `index.json`.
3. Abra um PR.
