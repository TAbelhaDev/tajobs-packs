<div align="center">

# tjobs-packs

**English** · [Português](README.pt-BR.md)

[![License: AGPL-3.0](https://img.shields.io/badge/license-AGPL--3.0-blue?style=flat-square)](LICENSE)

[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/ianptkcs)

</div>

---

Registry of job packs for [tjobs](https://github.com/TAbelhaDev/tajobs):
shareable terminal jobs that anyone installs with a single command, reviews,
and only then arms.

A **pack** is an ordinary [tjobs job directory](https://github.com/TAbelhaDev/tajobs#the-job-convention)
plus a `<name>.pack.toml` manifest. Installing never runs anything: a pack
with a suggested schedule lands as a **paused timer**, one without lands as a
**manual job**. You read the script first; the schedule only fires after you
arm it (`t` in the tjobs TUI).

## Install

```bash
# from this registry (subdir install)
tjobs install https://github.com/TabelaDev/tjobs-packs#model-monitor

# or browse interactively inside the tjobs TUI: press p

# or straight from any git repo / local path, no registry needed
tjobs install /path/to/some/pack-dir
```

Then review the script and arm it:

| Pack ships with        | Lands as     | How to go live            |
| ---------------------- | ------------ | ------------------------- |
| `schedule` in manifest | paused timer | review, then press `t`    |
| no `schedule`          | manual job   | review, then run with `x` |

## Available packs

| Name            | What it does                                                                                          | Suggested schedule |
| --------------- | ----------------------------------------------------------------------------------------------------- | ------------------ |
| `model-monitor` | Watches LLM pricing via models.dev: free→paid alerts, price moves on your watchlist providers, and new free models anywhere | every 6h           |

`tjobs packs list` always shows the current registry contents.

## Writing your own pack

```
my-pack/
  my-pack.sh           # the script (tjobs job convention)
  my-pack.pack.toml    # the manifest
```

`my-pack.pack.toml`:

```toml
name = "my-pack"
description = "What it does, shown in listings"
author = "you"
source = "https://github.com/TabelaDev/tjobs-packs"  # enables `tjobs packs update`
schedule = "*-*-* 09:00:00"                          # optional suggested OnCalendar
```

Rules of thumb:

- Scripts must follow the [tjobs job convention](https://github.com/TAbelhaDev/tajobs/blob/main/instructions.md)
  (`set -euo pipefail`, self-cleanup tail for one-shots, none for recurring).
- Network-touching jobs must wait for connectivity before doing anything.
- Keep packs flat: script + manifest + optional notes/sidecars. Logs are
  runtime state and are never part of a pack.

## Submitting a pack

1. Add `<your-pack>/` with its script and manifest.
2. Add an entry to `index.json`.
3. Open a PR. After merge, it shows up for everyone via `tjobs packs list`
   and in the TUI browser (`p`).

## License

[AGPL-3.0](LICENSE)
