#!/bin/sh
# Affiche les logs.
# Usage:
#   ./tools/logs.sh              # suit les logs dsh
#   ./tools/logs.sh --all        # tous les services
#   ./tools/logs.sh --tail 100   # 100 dernières lignes sans follow
set -e
cd "$(dirname "$0")/.."

case "${1:-}" in
  --all) exec docker compose logs -f ;;
  --tail) exec docker compose logs --tail="${2:-100}" dsh ;;
  "") exec docker compose logs -f dsh ;;
  *) exec docker compose logs "$@" ;;
esac
