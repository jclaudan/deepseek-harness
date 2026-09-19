# 02 — Settings (LAN writable)

## Problème initial
Sur `https://192.168.1.29:3443` (hostname non-loopback) la page Models affichait :
- `Loading the provider directory failed: settings are unavailable in this browser`
- puis `The settings document is read-only in this deployment.`

Cause : `packages/client/ui-settings/src/client/settings-mirror.ts:89` → `persistence='memory'` si `!isLoopback && !remoteSettings`. `ModelsSettingsStore:188` faisait `failLoad` au lieu d'afficher les rows.

## Fix

### 1. `packages/client/ui-settings/src/client/index.ts:40`
```ts
export interface Config { remoteSettings: boolean }
export const Config = z.object({ remoteSettings: z.boolean().default(true) }) // était false
// ...
const persistence = (isLoopback || remoteSettings) ? 'host' : 'memory'
```
Par défaut `true` → zéro-config sur nouvelle machine (LAN éditable). Opt-out : `remoteSettings:false` ou `DSH_REMOTE_SETTINGS=0`.

### 2. `packages/client/ui-settings-models/src/client/store.ts:182`
`load()` n'échoue plus si `view===undefined` (memory) → `writable=false`, `namespaces=[]` mais `rows` chargés en `ready`. Avant : `failLoad('settings are unavailable...')`.

### 3. `docker-compose.yml:14` / `docker/entrypoint.sh:13`
Compose défaut `1`, entrypoint ne patch `false` que si `DSH_REMOTE_SETTINGS=0`.

## Flux
```
Browser https://192.168.1.29:3443
  → pageLocation.hostname=192.168.1.29 → isLoopback=false (packages/client/connection/src/client/index.ts:233)
  → ui-settings Config.remoteSettings=true (défaut) → persistence='host'
  → SettingsDescribeMirror:load() → remote.settings.describe() → Host FileSettingsProvider (writable:true) → view.writable=true
  → ModelsSection:312 `!state.writable` false → pas de bandeau, boutons Edit/Add actifs
```

## Config restante
- `TRUSTED_HOSTS` dans `.env` → `docker-compose.yml:11` → `entrypoint.sh:24` `--trusted-host` (fence `isLoopbackHostname` + `isTrustedAuthority`)
- `settings.yaml` sous `/root/.dsh/settings.yaml` (volume `dsh-home`), `FileSettingsProvider:143` toujours writable

## Désactiver LAN writable
```sh
DSH_REMOTE_SETTINGS=0 ./tools/up.sh --read-only
# ou export DSH_REMOTE_SETTINGS=0 && ./tools/up.sh
```
