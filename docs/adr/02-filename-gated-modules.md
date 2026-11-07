# Tool modules are gated by their filename

A file in `bash/env.d/` or `bash/cmds/` is sourced only when its filename is a
command found by `command -v` (`__src_tool_modules` in `bash/utility`). This
means adding or removing a tool needs no config edits and costs nothing when the
tool is absent.

The trade-offs:

- Any command on `PATH` satisfies the gate, wherever it is installed (for
  example, `/usr/bin/cargo`).
- Self-sourced PATH: a tool installed only in a directory that its own
  module adds (for example, cargo only in `$CARGO_HOME/bin`) is never found,
  because the module is skipped before it can add that directory.
- Modules load in lexical order, so a tool's environment must not depend on
  another tool's module.
