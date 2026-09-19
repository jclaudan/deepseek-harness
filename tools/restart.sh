#!/bin/sh
set -e
# Restart rapide (sans rebuild). LAN writable par défaut.
# Usage: ./tools/restart.sh [--read-only]
cd "$(dirname "$0")/.."
READONLY=""
for arg in "$@"; do
  case "$arg" in --read-only) READONLY=1 ;; --remote) ;; esac # --remote compat no-op
done
"$(dirname "$0")/down.sh"
if [ "$READONLY" = "1" ]; then
  exec "$(dirname "$0")/up.sh" --read-only
else
  if [ "${DSH_REMOTE_SETTINGS:-1}" = "0" ]; then
    exec "$(dirname "$0")/up.sh" --read-only
  else
    exec "$(dirname "$0")/up.sh"
  fi
fi
