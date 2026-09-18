#!/bin/sh
set -e
# Stoppe et supprime les conteneurs (garde les volumes).
# Usage: ./tools/down.sh
cd "$(dirname "$0")/.."
exec docker compose down
