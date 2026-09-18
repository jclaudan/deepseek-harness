#!/bin/sh
set -e
# Stoppe, supprime les conteneurs ET les volumes (dsh-home, dsh-data) + réseau.
# ⚠️  Destructif : efface les données persistées en volumes Docker.
# Usage: ./tools/down-volumes.sh
#   Demande confirmation avant d'exécuter.
cd "$(dirname "$0")/.."

printf "⚠️  Supprimer les VOLUMES Docker (dsh-home, dsh-data) ? [y/N] "
read -r ans
case "$ans" in
  y|Y|yes|YES) ;;
  *) echo "Annulé."; exit 0 ;;
esac

exec docker compose down -v
