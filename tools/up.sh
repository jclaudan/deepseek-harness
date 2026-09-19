#!/bin/sh
set -e
# Lance dsh + searxng en détaché. LAN éditable par défaut.
# Usage:
#   ./tools/up.sh                # LAN writable (défaut)
#   ./tools/up.sh --read-only    # LAN read-only (DSH_REMOTE_SETTINGS=0)
#   ./tools/up.sh --build        # rebuild avant up
#   ./tools/up.sh --read-only --build
# Compat: --remote reste accepté (no-op, défaut déjà writable)
cd "$(dirname "$0")/.."

REMOTE="1"
BUILD=""

for arg in "$@"; do
  case "$arg" in
    --remote) REMOTE=1 ;; # compat : déjà le défaut
    --read-only) REMOTE=0 ;;
    --build) BUILD=1 ;;
    --help|-h)
      echo "Usage: $0 [--read-only] [--build]"
      echo "  --read-only  force DSH_REMOTE_SETTINGS=0 (LAN read-only)"
      echo "  --remote     compat: LAN writable (défaut, no-op)"
      echo "  --build      rebuild l'image avant de lancer"
      exit 0
      ;;
    *) echo "Option inconnue: $arg (voir --help)" >&2; exit 1 ;;
  esac
done

if [ "$REMOTE" = "0" ]; then
  export DSH_REMOTE_SETTINGS=0
  echo "→ DSH_REMOTE_SETTINGS=0 (LAN read-only)"
else
  # Défaut writable : n'écrase pas un 0 explicite du shell
  if [ "${DSH_REMOTE_SETTINGS:-1}" = "0" ]; then
    echo "→ DSH_REMOTE_SETTINGS=0 (hérité du shell, LAN read-only)"
  else
    export DSH_REMOTE_SETTINGS=1
    echo "→ DSH_REMOTE_SETTINGS=1 (LAN writable, défaut)"
  fi
fi

if [ "$BUILD" = "1" ]; then
  echo "→ build + up"
  exec docker compose up -d --build
else
  exec docker compose up -d
fi
