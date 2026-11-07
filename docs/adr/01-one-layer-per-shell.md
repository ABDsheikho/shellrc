# One layer per shell

Each shell gets its own entry points and fragment directory, written in that
shell's native syntax: today `bashrc`, `bash_profile`, and `bash/`; zsh would
add `zshrc`, `zprofile`, and `zsh/`. Layers share no code. Adding a shell never
touches another shell's files, and each layer can use its shell's own features
(Bash's `PROMPT_COMMAND` array, `shopt`, and readline; zsh's `precmd` and ZLE)
and that shell's tool integrations (`starship init bash`, `fzf --bash`, ...).

## Considered Options

- **One POSIX `sh` codebase for every shell.** Rejected. POSIX has no prompt
  hooks, history controls, or key bindings, and those are most of the config.
  Shells also read different startup files (`.bashrc`, `.zshrc`, `$ENV` for
  dash), so each one needs its own entry points anyway.
- **A shared environment layer** (XDG, `PATH`, tool homes) sourced by every
  shell. Rejected for now. It would save a few duplicated lines, but it ties
  that code to syntax every shell accepts and makes changes there affect all
  layers. Revisit if the duplication actually grows.
