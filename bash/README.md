# `bash/`: changing the Bash layer

How the Bash fragments divide the work, and how to add to them. For setup and
behavior, see the [top README](../README.md).

## Who owns what

| File | Runs in | Owns |
| --- | --- | --- |
| `utility` | every shell | Shared helpers: `__path_add`, `__src_tool_modules`, `__bash_cache_init` |
| `env` | every shell | XDG defaults, `HISTFILE`, editor/pager, user `PATH` entries, loading `env.d/` |
| `env.d/<cmd>` | every shell | One tool's environment variables and `PATH` entries |
| `core` | interactive | Shell options, history settings, the history-sync prompt hook |
| `ui` | interactive | Prompt: starship, or the static fallback |
| `aliases` | interactive | General aliases and small functions |
| `cmds/<cmd>` | interactive | One tool's aliases, functions, hooks, and shell integration |

"Every shell" means every shell that reads `bashrc`, including `bash -lc` and
SSH commands ([ADR 03](../docs/adr/03-env-before-interactive-guard.md)).

## Tool modules: `env.d/` and `cmds/`

Both directories are loaded by `__src_tool_modules`. A file is sourced only
when its **filename is a command** on `PATH`, so `cmds/fzf` loads only if
`fzf` is installed ([ADR 02](../docs/adr/02-filename-gated-modules.md)).
Modules load in lexical order.

Choose the directory by when the setting is needed:

- **`env.d/`**: variables or `PATH` entries a script or SSH command may need.
  Must be quiet and fast, and must not assume a terminal.
- **`cmds/`**: anything only a person at a prompt uses: aliases, functions,
  `PROMPT_COMMAND` hooks, `eval "$(tool init bash)"`.

A tool can have a file in both (for example, `cargo` variables in `env.d/` and
cargo aliases in `cmds/`).

## Adding a module

1. Name the file exactly after the command, in `env.d/` or `cmds/`.
2. Start it with `#!/bin/bash`. The shebang is documentation only; the file
   is sourced.
3. Respect values already set: `export FOO_HOME="${FOO_HOME:-$XDG_DATA_HOME/foo}"`.
4. Add directories with `__path_add <append|prepend> <dir>`. It skips missing
   directories and duplicates.
5. Cache generated init scripts, with `eval` as the fallback:

   ```bash
   if ! __bash_cache_init foo.bash "$(command -v foo)" foo init bash; then
       eval "$(foo init bash)"
   fi
   ```

   If you add one, also add it to the cache table in `../checkhealth`.
6. Add prompt hooks to the `PROMPT_COMMAND` array only if they aren't already
   there (see `cmds/foot`). A hook that must survive starship goes into
   element 0 (see `core`).
7. Run `./checkhealth`.

## Conventions

- Native Bash syntax, not POSIX: `[[ ]]`, `(( ))`, `printf` rather than
  `echo` for data ([ADR 01](../docs/adr/01-one-layer-per-shell.md)).
- Helpers that are internal to the config are prefixed with `__`.
- No output on startup; `./checkhealth` fails if interactive startup writes
  to stderr.
