#!/bin/sh
set -e
# Build l'image dsh (node + nginx) sans la lancer.
# Usage: ./tools/build.sh [--no-cache]
#   --no-cache  force rebuild complet (utile après changement Dockerfile/base image)
cd "$(dirname "$0")/.."
case "${1:-}" in
  --help|-h)
    echo "Usage: $0 [--no-cache]"
    echo "  --no-cache  force rebuild complet"
    exit 0
    ;;
  --no-cache) exec docker compose build --no-cache dsh ;;
  "") exec docker compose build dsh ;;
  *) echo "Option inconnue: $1 (voir --help)" >&2; exit 1 ;;
esac
