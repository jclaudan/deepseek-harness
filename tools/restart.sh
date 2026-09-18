#!/bin/sh
set -e
# Restart rapide (sans rebuild).
# Usage: ./tools/restart.sh [--remote]
cd "$(dirname "$0")/.."
REMOTE_FLAG=""
for arg in "$@"; do
  case "$arg" in --remote) REMOTE_FLAG="--remote" ;; esac
done
# shellcheck disable=SC2086
"$(dirname "$0")/down.sh"
if [ "$REMOTE_FLAG" = "--remote" ]; then
  exec "$(dirname "$0")/up.sh" --remote
else
  # préserve DSH_REMOTE_SETTINGS du shell si déjà exporté
  if [ "${DSH_REMOTE_SETTINGS:-}" = "1" ]; then
    exec "$(dirname "$0")/up.sh" --remote
  else
    exec "$(dirname "$0")/up.sh"
  fi
fi
