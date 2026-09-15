# README — Docker + Nginx proxy pour DeepSeek Harness

Ce README explique ce que j'ai ajouté sur la branche docker/dsh-nginx-proxy-3080 et comment l'utiliser.

Contexte
- Le projet DeepSeek Harness a un CLI `dsh web` qui, par conception, peut refuser d'écouter 0.0.0.0 et se bind uniquement sur 127.0.0.1.
- Si le processus Node s'exécute dans un conteneur et n'écoute que sur 127.0.0.1, Docker ne peut pas exposer le port vers l'extérieur.
- Solution apportée : lancer l'application Node dans le conteneur (écoute locale 127.0.0.1) et démarrer Nginx dans le même conteneur pour écouter 0.0.0.0:3080 et reverse-proxy vers 127.0.0.1:3080. Ainsi l'UI est accessible depuis d'autres machines du LAN sans modifier le code.

Ce que j'ai ajouté (branche)
- Branche : docker/dsh-nginx-proxy-3080
  https://github.com/jclaudan/deepseek-harness/tree/docker%2Fdsh-nginx-proxy-3080

- Fichiers ajoutés sur la branche :
  - Dockerfile
  - docker/nginx/dsh.conf
  - docker/entrypoint.sh
  - docker-compose.yml
  - .env.example
  - DOCKER-README.md (ce fichier)

Rôles des fichiers
- Dockerfile
  - Image basée sur node:24-bullseye-slim
  - Installe pnpm, nginx et netcat
  - Installe les dépendances pnpm et lance `pnpm run build`
  - Copie la configuration nginx et le script d'entrypoint

- docker/nginx/dsh.conf
  - Nginx écoute sur le port 3080 et proxy_pass vers http://127.0.0.1:3080

- docker/entrypoint.sh
  - Construit la ligne de commande pour `dsh web --no-open --port 3080` (ajoute --trusted-host pour chaque entrée dans la variable TRUSTED_HOSTS)
  - Lance `pnpm run dsh -- ...` en arrière-plan et attend que le port local 127.0.0.1:3080 soit joignable (probe TCP)
  - Démarre nginx en foreground (`nginx -g 'daemon off;'`)

- docker-compose.yml
  - Service `dsh` qui build l'image et mappe le port 3080:3080
  - Variable TRUSTED_HOSTS laissée vide par défaut — remplissez via .env ou environment

- .env.example
  - Exemples de variables (DSH_PORT, TRUSTED_HOSTS, DATABASE_URL, REDIS_URL, secrets, etc.)
  - Copiez en `.env` et adaptez les valeurs

Utilisation — étapes rapides
1) Récupérer la branche localement
   git fetch origin
   git checkout docker/dsh-nginx-proxy-3080

2) Créer votre .env à partir de l'exemple et le remplir
   cp .env.example .env
   # Éditez .env et mettez TRUSTED_HOSTS, SESSION_SECRET, DATABASE_URL, etc.

   Exemple: dans .env
   TRUSTED_HOSTS="192.168.1.10:3080"

3) Construire et lancer avec Docker Compose
   docker compose up --build
   (ou) docker-compose up --build

4) Accéder depuis une autre machine du LAN
   - Récupérez l'IP de la machine hôte Docker (ex: 192.168.1.10)
   - Ouvrez dans un navigateur : http://192.168.1.10:3080
   - Si l'app bloque certaines requêtes selon l'origine, ajustez TRUSTED_HOSTS (IP:PORT) dans .env

Logs & debug
- Logs d'application (redirigés par l'entrypoint) : /var/log/dsh-web.log dans le conteneur
- Logs nginx : /var/log/nginx/
- Visualiser les logs depuis l'hôte :
  docker-compose logs -f dsh
  docker logs -f deepseek-dsh
- Si le conteneur échoue, exécutez :
  docker-compose ps
  docker-compose logs dsh
  docker exec -it deepseek-dsh tail -n 200 /var/log/dsh-web.log

Options & variantes
- Mode développement : vous pouvez monter votre code local dans le conteneur pour dev rapide (décommenter volumes dans docker-compose) et modifier l'entrypoint pour lancer `pnpm run dev:web` au lieu de `pnpm run dsh -- web ...`.
- Image plus légère / prod : convertir le Dockerfile en multi-stage (builder + runtime minimal) pour réduire la taille finale.

Sécurité & bonnes pratiques
- Ne commitez jamais le fichier `.env` contenant des secrets.
- Utilisez des secrets forts pour SESSION_SECRET et JWT_SECRET.
- N'exposez pas directement le service sur Internet sans reverse-proxy TLS / auth.

Prochaines actions que je peux faire pour vous
- Pré-remplir TRUSTED_HOSTS dans docker-compose.yml ou .env.example avec une IP (si vous me la donnez)
- Ajouter une variante `docker-compose.dev.yml` pour travail local (volume + watchers)
- Convertir le Dockerfile en multi-stage
- Ouvrir une Pull Request depuis cette branche vers la branche principale

Si vous voulez que j'ajoute quelque chose au README (exemples de commandes, screenshots, notes spécifiques au déploiement), dites-moi ce que vous voulez inclure et je mettrai à jour le fichier.
