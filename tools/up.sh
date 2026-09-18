#!/bin/sh
set -e
# Lance dsh + searxng en détaché.
# Usage:
#   ./tools/up.sh                # lecture seule sur LAN (défaut)
#   ./tools/up.sh --remote       # ou DSH_REMOTE_SETTINGS=1 ./tools/up.sh -> settings persistants LAN
#   ./tools/up.sh --build        # rebuild avant up
#   ./tools/up.sh --remote --build
cd "$(dirname "$0")/.."

REMOTE=""
BUILD=""

for arg in "$@"; do
  case "$arg" in
    --remote) REMOTE=1 ;;
    --build) BUILD=1 ;;
    --help|-h)
      echo "Usage: $0 [--remote] [--build]"
      echo "  --remote  active DSH_REMOTE_SETTINGS=1 (settings Host persistants sur IP LAN)"
      echo "  --build   rebuild l'image avant de lancer"
      exit 0
      ;;
    *) echo "Option inconnue: $arg (voir --help)" >&2; exit 1 ;;
  esac
done

if [ "$REMOTE" = "1" ]; then
  export DSH_REMOTE_SETTINGS=1
  echo "→ DSH_REMOTE_SETTINGS=1 (LAN writable)"
else
  # n'écrase pas si déjà exporté dans le shell
  if [ "${DSH_REMOTE_SETTINGS:-}" = "1" ]; then
    echo "→ DSH_REMOTE_SETTINGS=1 (hérité du shell)"
  else
    echo "→ LAN read-only (passe --remote pour writable)"
  fi
fi

if [ "$BUILD" = "1" ]; then
  echo "→ build + up"
  exec docker compose up -d --build
else
  exec docker compose up -d
fi
