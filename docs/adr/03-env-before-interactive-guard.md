# Environment loads before the interactive guard

`bashrc` sources `utility` and `env` (XDG paths, `env.d`, `PATH`) *before* it
returns for non-interactive shells, so `bash -lc` and commands run over SSH get
the configured `PATH`. Everything after the guard (`core`, `ui`, `aliases`,
`cmds`) is interactive-only. As a result, `env` and every `env.d` module must
be cheap, silent, and safe to run in non-interactive shells. Plain `bash -c`,
cron, and systemd units do not read `bashrc` at all.
