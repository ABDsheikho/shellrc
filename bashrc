#!/bin/bash

# Only load once per shell; `srcbashrc` starts a fresh shell.
if [[ -n ${BASHRC_LOADED:-} ]]; then
    return
fi
BASHRC_LOADED=1

# Resolve this file's directory so the sources below work from any cwd.
#
# Alternative without the ~2 ms dirname/subshell fork, at the cost of not
# canonicalizing the path (no `pwd -P`, so `..` and symlinks are kept as-is).
# The second line handles being sourced by bare name, where `%/*` leaves the
# name unchanged and the directory is therefore the current one.
# BASHRC_DIR=${BASH_SOURCE[0]%/*}
# [[ $BASHRC_DIR == "${BASH_SOURCE[0]}" ]] && BASHRC_DIR=.
BASHRC_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

# Environment and PATH are needed by every shell that reads this file,
# including non-interactive login shells and sshd-invoked shells.
source "$BASHRC_DIR/bash/env"
source "$BASHRC_DIR/bash/path"

# Everything below is interactive-only.
case $- in
*i*) ;;
*) return ;;
esac

# Readline config lives in this repo rather than $XDG_CONFIG_HOME/readline.
export INPUTRC="$BASHRC_DIR"/inputrc

source "$BASHRC_DIR/bash/core"
source "$BASHRC_DIR/bash/ui"
source "$BASHRC_DIR/bash/aliases"

for file in "$BASHRC_DIR"/bash/cmds/*; do
    [[ -f $file ]] || continue
    command -v "${file##*/}" >/dev/null 2>&1 || continue
    source "$file"
done
