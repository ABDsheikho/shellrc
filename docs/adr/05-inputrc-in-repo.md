# Readline config lives in this repo

Interactive shells export `INPUTRC="$BASHRC_DIR/inputrc"` instead of relying on
`~/.inputrc` or `$XDG_CONFIG_HOME/readline/inputrc`, so the key bindings move
with the clone wherever it lives. The catch: readline programs that are not
started from such a shell (a desktop launcher, a cron job) never see
`INPUTRC` and fall back to their default inputrc.
