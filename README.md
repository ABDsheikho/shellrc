# Shell configuration

A small modular shell configuration with one layer per shell
([ADR 01](docs/adr/01-one-layer-per-shell.md)). Each layer has its own entry
points and fragment directory. Today there is the Bash layer: `bashrc` and
`bash_profile` load the fragments in `bash/` once per shell. Supporting another
shell means adding its own files (for zsh: `zshrc`, `zprofile`, `zsh/`); the
Bash files stay untouched. To change or extend the Bash layer, see
[`bash/README.md`](bash/README.md).

## Requirements

- Bash 5.1 or newer for the Bash layer (its prompt hooks use the array form
  of `PROMPT_COMMAND`).
- Linux and the usual GNU userland.
- Optional tools each enable a module when present (starship, fzf, zoxide,
  foot, cargo, go, ...). `./checkhealth --env` lists which ones load here.

## Setup

Clone the repository to `~/.config/shellrc` (the path used throughout this
README):

```bash
git clone git@github.com:ABDsheikho/shellrc.git ~/.config/shellrc
```

Then activate it by sourcing the two entry points from your shell's own rc
files. Append the lines rather than replacing the files, so your existing
setup keeps working:

```bash
echo 'source ~/.config/shellrc/bashrc' >> ~/.bashrc
echo 'source ~/.config/shellrc/bash_profile' >> ~/.bash_profile
```

If you clone somewhere else, use that path in both lines. If your system reads
`~/.bash_login` or `~/.profile` instead of `~/.bash_profile`, put the second
line there. Open a new shell (or `exec bash`), then run `./checkhealth`.

## Load order

1. `bash/utility`: shared helpers (`__path_add`, `__src_tool_modules`,
   `__bash_cache_init`).
2. `bash/env`: XDG paths, `HISTFILE`, editor and pager, `PATH`, and the
   `bash/env.d/*` modules.

Non-interactive shells stop here, so `bash -lc` and SSH commands still get the
environment ([ADR 03](docs/adr/03-env-before-interactive-guard.md)).
Interactive shells continue with `INPUTRC`, then `bash/core` (shell options,
history), `bash/ui` (prompt), `bash/aliases`, and the `bash/cmds/*` modules.
A module loads only when its filename is an installed command
([ADR 02](docs/adr/02-filename-gated-modules.md)).

## Behavior

Only what the code doesn't make obvious:

- **Reload with `srcbashrc`** (`exec bash`). Re-sourcing `~/.bashrc` is a
  no-op on purpose (`BASHRC_LOADED` guard); otherwise prompt hooks would be
  added twice.
- **History is shared live.** Every prompt runs `history -a` then `history -n`,
  so concurrent shells see each other's commands without rewriting the file.
  `dhist` (needs fzf) deletes picked entries from memory and `$HISTFILE`.
- **Prompt.** starship owns `PS1` when installed; otherwise a static
  `[time] user@host:dir $` prompt is used.
- **Starship keeps only element 0 of `PROMPT_COMMAND`.** A hook that must
  survive starship has to be folded into element 0, as `__bash_history_sync`
  is. Hooks in later elements run, but outside starship's chain.
- **Tool init is cached** in `~/.cache/bash/` and refreshed only when the tool
  binary changes ([ADR 04](docs/adr/04-init-cache-mtime-only.md)).
- **Readline edits** apply to a running shell with `bind -f "$INPUTRC"`.
- **`cd` is zoxide** when zoxide is installed: `cd <query>` jumps, a bare `cd`
  opens the interactive picker.

## Testing

```bash
./checkhealth            # both sections
./checkhealth --config   # only the config checks
./checkhealth --env      # only the report on this machine
```

- **Config** loads the repo in a throwaway `HOME` with a minimal `PATH`, so it
  never touches your history, cache, or ssh-agent. It checks syntax, that
  startup defines the helpers without errors, that non-interactive shells get
  `PATH` without duplicates, that pre-set XDG paths are kept, and the
  `__path_add` contract. Any FAIL exits non-zero.
- **Environment** reports on your machine: Bash version, whether the home entry
  points source this repo, `INPUTRC`, which modules load, whether each init
  cache matches its tool's current output, and whether ssh-agent answers.
  WARN never changes the exit status.

## Troubleshooting

- **Hooks run twice?** Use `srcbashrc`, not `source ~/.bashrc`.
- **A tool behaves like its old version?** Clear `~/.cache/bash` and restart;
  `./checkhealth --env` shows stale caches.
- **Inspect state:** `declare -p PROMPT_COMMAND`, `printf '%s\n' "$HISTFILE"`,
  `path` (one `PATH` entry per line).

## Design decisions

Recorded as short ADRs in [`docs/adr/`](docs/adr/), named `NN-slug.md`. When a
decision changes, add a new ADR that supersedes the old one instead of
editing it.

- [01](docs/adr/01-one-layer-per-shell.md): one layer per shell, no shared code
- [02](docs/adr/02-filename-gated-modules.md): tool modules are gated by their filename
- [03](docs/adr/03-env-before-interactive-guard.md): environment loads before the interactive guard
- [04](docs/adr/04-init-cache-mtime-only.md): init cache is invalidated by mtime only
- [05](docs/adr/05-inputrc-in-repo.md): readline config lives in this repo

## Known issues and future work

- **SSH agent race.** Two shells starting together can both see a dead socket;
  one may unlink the socket the other's new agent just bound, orphaning it.
  Fix: serialize check/remove/start with `flock`, or use a systemd user socket.
- **Cache version stamp.** Detect version/flag changes the mtime check misses,
  and add a refresh command.
- **zsh layer.** Add `zshrc`, `zprofile`, and `zsh/`
  ([ADR 01](docs/adr/01-one-layer-per-shell.md)).
- Keep the `~/.bashrc` / `~/.bash_profile` stubs in line with [Setup](#setup).

## License

[0BSD](LICENSE): use, copy, and modify freely; no attribution required.
