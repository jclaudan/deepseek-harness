# 05 — Troubleshooting

## `Loading the provider directory failed: settings are unavailable in this browser`
Fix `packages/client/ui-settings-models/src/client/store.ts:182` — maintenant `ready` read-only au lieu de `error`. Si tu le revois : image non rebuild → `./tools/build.sh && ./tools/up.sh --build` + hard refresh.

## `The settings document is read-only in this deployment.`
- Avant `2d9031d` : LAN sans `DSH_REMOTE_SETTINGS=1` → `memory`
- Depuis `2d9031d` : défaut `remoteSettings:true` → LAN writable. Si tu le vois : `DSH_REMOTE_SETTINGS=0` actif ou fichier Host vraiment RO. Vérifie `docker compose exec dsh env | grep DSH_REMOTE` doit être `1` (ou vide → défaut `1`).

## `DSH_REMOTE_SETTINGS` dans `.env` → boot error
`packages/boot/app-boot/src/index.ts:175` rejette `DSH_*` dans `.env`. Exporter :
```sh
DSH_REMOTE_SETTINGS=0 ./tools/up.sh --read-only
```

## `unknown option '--patch'`
Ancien `docker/entrypoint.sh` faisait `pnpm run dsh -- web --patch ... --trusted-host` où `--patch` était après `--trusted-host` + `pnpm` injectait `--` → Commander le voyait comme app option. Fix : `--patch` avant `--port` et `node --import tsx/esm apps/cli/src/bin.ts` direct.

## `EADDRINUSE 127.0.0.1:3081`
Ancien entrypoint relançait `dsh web` en boucle sans tuer l'ancien pid. Fix + `tools/restart.sh`.

## `cc ENOENT` au build
`native/system` besoin `build-essential python3` → `Dockerfile:6` fix `16cbff64`.

## Logs
```sh
./tools/logs.sh
docker compose exec dsh cat /var/log/dsh-web.log
docker compose exec dsh cat /usr/local/bin/entrypoint.sh | grep -A2 "Starting dsh"
docker compose exec dsh node --import tsx/esm apps/cli/src/bin.ts --profile web --dump-config | grep -A3 ui-settings
```

## Cache browser
Après chaque rebuild : `Ctrl+Shift+R` sur `https://192.168.1.29:3443`.
