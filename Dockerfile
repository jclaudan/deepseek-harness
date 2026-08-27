FROM node:24-bookworm-slim

# Installer utilitaires, pnpm, nginx et netcat
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates curl gnupg2 nginx netcat-openbsd git \
  && rm -rf /var/lib/apt/lists/*

# Activer corepack et préparer pnpm exact
RUN corepack enable && corepack prepare pnpm@11.7.0 --activate

WORKDIR /usr/src/app

COPY . .

# Installer les dépendances (workspace)
RUN pnpm install --frozen-lockfile --prefer-offline

# Build : prépare lib/dist utilisés par "dsh web"
RUN pnpm run build

# Config nginx : supprime la conf par défaut et installe la nôtre
RUN rm -f /etc/nginx/conf.d/default.conf /etc/nginx/sites-enabled/default
COPY docker/nginx/dsh.conf /etc/nginx/conf.d/dsh.conf

# Script d'entrée pour lancer le serveur Node puis nginx
COPY docker/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 3080

CMD ["/usr/local/bin/entrypoint.sh"]
