# 04 — Tools (`tools/`)

Dossier créé pour laisser **toi** choisir l'action (build séparé, up, down, down -v).

| Script | Fait | Équivaut à |
|---|---|---|
| `tools/build.sh [--no-cache]` | build image `dsh` | `docker compose build dsh` |
| `tools/up.sh [--read-only] [--build]` | up détaché, LAN writable par défaut | `docker compose up -d [--build]` |
| `tools/down.sh` | down (garde volumes) | `docker compose down` |
| `tools/down-volumes.sh` | down -v avec confirm `y/N` | `docker compose down -v` |
| `tools/logs.sh [--all\|--tail N]` | logs | `docker compose logs -f dsh` |
| `tools/restart.sh [--read-only]` | down + up | |

Compat : `--remote` reste accepté comme no-op (défaut déjà writable).

```sh
./tools/build.sh
./tools/up.sh                # zéro-config, LAN éditable
./tools/up.sh --build
./tools/up.sh --read-only    # force LAN read-only
DSH_REMOTE_SETTINGS=0 ./tools/up.sh --read-only

./tools/logs.sh --tail 100
./tools/down.sh
./tools/down-volumes.sh      # ⚠️ rase dsh-home + dsh-data
```

Volumes : `dsh-home:/root/.dsh` (settings, credentials, sessions), `dsh-data:/usr/src/app/data`. `TRUSTED_HOSTS` via `.env`, `DSH_REMOTE_SETTINGS` via env (jamais dans `.env`).

Voir `tools/README.md` pour le détail.
