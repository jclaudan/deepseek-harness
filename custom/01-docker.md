# 01 — Docker + Nginx

## Pourquoi
`dsh web` bind `127.0.0.1` par défaut. Dans Docker, `127.0.0.1` n'est pas exposable. On ajoute Nginx qui écoute `0.0.0.0:3080`/`3443` et proxy vers `127.0.0.1:3081`.

## Fichiers

### `Dockerfile:1`
- Base `node:24-bookworm-slim`, `apt` : `ca-certificates curl gnupg2 nginx netcat-openbsd git openssl build-essential python3` (le `cc` manquant causait `ENOENT` sur `native/system` → fix `16cbff64`)
- `pnpm install --prefer-offline` + `pnpm run build` (génère `apps/web/dist`, `lib/`)
- Nginx : supprime `default.conf`, installe `docker/nginx/dsh.conf`, génère cert self-signed `CN=192.168.1.29` `SAN IP:192.168.1.29,IP:127.0.0.1,DNS:localhost`
- `COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh`

### `docker/nginx/dsh.conf:1`
```nginx
listen 3080; listen 3443 ssl;
proxy_pass http://127.0.0.1:3081;
```
Certs `/etc/nginx/certs/{fullchain,privkey}.pem`.

### `dockerCompose:docker-compose.yml:1`
```yaml
services:
  dsh:
    build: .
    ports: ["3080:3080", "3443:3443"]
    environment:
      TRUSTED_HOSTS: "${TRUSTED_HOSTS:-}"
      DSH_REMOTE_SETTINGS: "${DSH_REMOTE_SETTINGS:-1}" # défaut LAN writable
      DEEPSEEK_BASE_URL / DEEPSEEK_API_KEY / DSH_WEB_SEARCH_PROVIDER / SEARXG_BASE_URL
    volumes: [dsh-home:/root/.dsh, dsh-data:/usr/src/app/data]
  searxng: {image: searxng/searxng:latest, ports: 8080:8080}
volumes: {dsh-home, dsh-data}
```
`TRUSTED_HOSTS` vide = seul `localhost` accepté (Host header check `packages/client/connection/src/api-request-trust.ts:103`).

### `docker/entrypoint.sh:1`
- `APP_PORT=3081`
- `DSH_PATCH_ARGS` : si `DSH_REMOTE_SETTINGS=0/false` → patch `ui-settings:{remoteSettings:false}`, sinon rien (défaut `true` depuis `packages/client/ui-settings/src/client/index.ts:45`)
- `DSH_CMD_ARGS="web${DSH_PATCH_ARGS} --no-open --port ${APP_PORT} --trusted-host ..."` — `--patch` **avant** `--port` (sinon Commander `unknown option '--patch'`), invocation directe `node --import tsx/esm apps/cli/src/bin.ts` (pas `pnpm run dsh --` qui injecte `--`)
- `nc -z 127.0.0.1:3081` probe puis `nginx -g 'daemon off;'`

### `.env.example:1` / `.env`
`TRUSTED_HOSTS="192.168.1.29"` (prod) / `""` (exemple). `DSH_*` bootstrap-only (`packages/boot/app-boot/src/index.ts:117`) → ne jamais mettre dans `.env`, exporter via shell.

## Build & run
```sh
./tools/build.sh [--no-cache]
./tools/up.sh              # LAN writable par défaut
DSH_REMOTE_SETTINGS=0 ./tools/up.sh --read-only
./tools/logs.sh
./tools/down.sh            # garde volumes
./tools/down-volumes.sh    # rase volumes (confirm y/N)
```
