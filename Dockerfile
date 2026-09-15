FROM node:24-bullseye-slim

# Installer utilitaires, pnpm, nginx et netcat
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg2 nginx netcat-openbsd \
  && rm -rf /var/lib/apt/lists/*

# Activer corepack et préparer pnpm exact
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate

WORKDIR /usr/src/app

# Copier les fichiers de workspace nécessaires pour installer les dépendances en cacheable layers
COPY package.json pnpm-lock.yaml pnpm-workspace.yaml ./

# Installer les dépendances (workspace)
RUN pnpm install --frozen-lockfile --prefer-offline

# Copier le reste du repo et builder
COPY . .

# Build : prépare lib/dist utilisés par "dsh web"
RUN pnpm run build

# Config nginx : on remplace la conf par la nôtre
COPY docker/nginx/dsh.conf /etc/nginx/conf.d/dsh.conf

# Script d'entrée pour lancer le serveur Node puis nginx
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3080

CMD ["/usr/local/bin/entrypoint.sh"]
