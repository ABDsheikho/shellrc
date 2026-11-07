# Tool init cache is invalidated by mtime only

`__bash_cache_init` caches generated init scripts (starship, zoxide, fzf) in
`$XDG_CACHE_HOME/bash/` and regenerates one only when it is missing or empty, or
when the tool binary is newer than the cache. This avoids spawning each tool on
every shell start. The cost is that changes to version, flags, or config that
leave the binary's mtime unchanged are not detected; clear `~/.cache/bash` to
force a refresh. A cache version stamp is listed as future work.
