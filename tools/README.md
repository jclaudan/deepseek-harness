# tools — scripts custom Docker

Scripts courts pour contrôler le stack `dsh`/`searxng` sans mémoriser les flags `docker compose`. Tu choisis : build séparé, up, down, down avec volumes.

| Script | Fait | Équivalent |
|---|---|---|
| `build.sh [--no-cache]` | build l'image `dsh` seule | `docker compose build dsh` |
| `up.sh [--read-only] [--build]` | lance en détaché (LAN writable par défaut) | `docker compose up -d [--build]` |
| `down.sh` | stop + rm conteneurs (garde volumes) | `docker compose down` |
| `down-volumes.sh` | stop + rm conteneurs **+ volumes** | `docker compose down -v` (demande confirmation) |
| `logs.sh [--all\|--tail N]` | suit les logs | `docker compose logs -f dsh` |
| `restart.sh [--read-only]` | down + up |  |

**LAN writable par défaut :** `DSH_*` est bootstrap-only (`packages/boot/app-boot/src/index.ts:117`) → ne pas mettre `DSH_REMOTE_SETTINGS` dans `.env`. Le compose l'interpole depuis l'environnement (`docker-compose.yml:14` défaut `1`) :

```sh
# défaut : LAN éditable (https://192.168.1.29:3443)
./tools/up.sh

# forcer read-only sur LAN
./tools/up.sh --read-only
# ou : DSH_REMOTE_SETTINGS=0 ./tools/up.sh
```

Le défaut `remoteSettings:true` (`packages/client/ui-settings/src/client/index.ts:45`) rend la page Models éditable même en partant de zéro sur une autre machine. L'entrypoint ne patch `remoteSettings:false` que si `DSH_REMOTE_SETTINGS=0`.

**TRUSTED_HOSTS** reste dans `.env` (`TRUSTED_HOSTS="192.168.1.29"`), lu par `docker-compose.yml:11`.

**Volumes :** `dsh-home:/root/.dsh` et `dsh-data:/usr/src/app/data`. `down-volumes.sh` efface tout (à n'utiliser que si tu veux repartir de zéro).
