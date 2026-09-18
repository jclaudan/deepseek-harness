# tools — scripts custom Docker

Scripts courts pour contrôler le stack `dsh`/`searxng` sans mémoriser les flags `docker compose`. Tu choisis : build séparé, up, down, down avec volumes.

| Script | Fait | Équivalent |
|---|---|---|
| `build.sh [--no-cache]` | build l'image `dsh` seule | `docker compose build dsh` |
| `up.sh [--remote] [--build]` | lance en détaché | `docker compose up -d [--build]` |
| `down.sh` | stop + rm conteneurs (garde volumes) | `docker compose down` |
| `down-volumes.sh` | stop + rm conteneurs **+ volumes** | `docker compose down -v` (demande confirmation) |
| `logs.sh [--all\|--tail N]` | suit les logs | `docker compose logs -f dsh` |
| `restart.sh [--remote]` | down + up |  |

**LAN writable :** `DSH_*` est bootstrap-only (`packages/boot/app-boot/src/index.ts:117`) → ne pas mettre `DSH_REMOTE_SETTINGS` dans `.env`. Le compose l'interpole depuis l'environnement :

```sh
# une fois (read-only par défaut)
./tools/up.sh

# settings persistants sur https://192.168.1.29:3443
./tools/up.sh --remote
# équivalent : DSH_REMOTE_SETTINGS=1 ./tools/up.sh
# ou        : export DSH_REMOTE_SETTINGS=1 && ./tools/up.sh
```

Le flag `--remote` exporte `DSH_REMOTE_SETTINGS=1` pour ce run ; l'entrypoint (`docker/entrypoint.sh:10`) génère alors `--patch` `ui-settings: {remoteSettings:true}` avant les app flags (`--trusted-host`).

**TRUSTED_HOSTS** reste dans `.env` (`TRUSTED_HOSTS="192.168.1.29"`), lu par `docker-compose.yml:11`.

**Volumes :** `dsh-home:/root/.dsh` et `dsh-data:/usr/src/app/data`. `down-volumes.sh` efface tout (à n'utiliser que si tu veux repartir de zéro).
