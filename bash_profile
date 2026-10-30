#!/bin/bash

# Resolve this file's directory so sourcing works from any cwd.
#
# Alternative without the ~2 ms dirname/subshell fork, at the cost of not
# canonicalizing the path (no `pwd -P`, so `..` and symlinks are kept as-is).
# The second line handles being sourced by bare name, where `%/*` leaves the
# name unchanged and the directory is therefore the current one.
# BASHRC_DIR=${BASH_SOURCE[0]%/*}
# [[ $BASHRC_DIR == "${BASH_SOURCE[0]}" ]] && BASHRC_DIR=.
BASHRC_DIR=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)

# No ~/.bashrc check: bashrc sits next to this file, and the BASHRC_LOADED
# guard prevents a double load if the login shell also reads ~/.bashrc.
source "$BASHRC_DIR/bashrc"
