#!/bin/sh
set -e

# Port app local (interne au conteneur, distinct du listen nginx 3080)
APP_PORT=3081

# Build argument list for dsh web
DSH_CMD_ARGS="web --no-open --port ${APP_PORT}"

# TRUSTED_HOSTS env : can contain one or more hosts separated by spaces
# e.g. TRUSTED_HOSTS="192.168.1.10:3080 192.168.1.11"
if [ -n "${TRUSTED_HOSTS}" ]; then
  for h in ${TRUSTED_HOSTS}; do
    DSH_CMD_ARGS="${DSH_CMD_ARGS} --trusted-host ${h}"
  done
fi

# Start the dsh web app in background, write logs
echo "Starting dsh web: pnpm run dsh -- ${DSH_CMD_ARGS}"
pnpm run dsh -- ${DSH_CMD_ARGS} >> /var/log/dsh-web.log 2>&1 &

DSH_PID=$!

# Wait for the local app to be ready (simple TCP probe)
echo "Waiting for local app to listen on 127.0.0.1:${APP_PORT}..."
RETRIES=60
i=0
while ! nc -z 127.0.0.1 ${APP_PORT}; do
  i=$((i+1))
  if [ ${i} -ge ${RETRIES} ]; then
    echo "Timeout waiting for dsh web to start; check /var/log/dsh-web.log"
    tail -n 200 /var/log/dsh-web.log || true
    kill ${DSH_PID} || true
    exit 1
  fi
  sleep 0.5
done
echo "dsh web is up (pid ${DSH_PID}). Starting nginx..."

# Start nginx in foreground (container main process)
nginx -g 'daemon off;'
