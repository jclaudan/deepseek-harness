#!/bin/sh
set -e

# Port app local (interne au conteneur, distinct du listen nginx 3080)
APP_PORT=3081

# Build argument list for dsh web
# Launcher flags (--patch) must come before app flags (--port/--trusted-host)
# or Commander treats them as unknown app options.
DSH_PATCH_ARGS=""
# DSH_REMOTE_SETTINGS: LAN browsers get durable Host settings by default
# (editable). Set to "0" to opt-out and keep LAN read-only (memory).
if [ "${DSH_REMOTE_SETTINGS}" = "0" ] || [ "${DSH_REMOTE_SETTINGS}" = "false" ]; then
  DSH_REMOTE_SETTINGS_PATCH=$(mktemp)
  cat > "${DSH_REMOTE_SETTINGS_PATCH}" <<'EOF'
- id: ui-settings
  config:
    remoteSettings: false
EOF
  DSH_PATCH_ARGS=" --patch ${DSH_REMOTE_SETTINGS_PATCH}"
fi
DSH_CMD_ARGS="web${DSH_PATCH_ARGS} --no-open --port ${APP_PORT}"

# TRUSTED_HOSTS env : can contain one or more hosts separated by spaces
# e.g. TRUSTED_HOSTS="192.168.1.10:3080 192.168.1.11"
if [ -n "${TRUSTED_HOSTS}" ]; then
  for h in ${TRUSTED_HOSTS}; do
    DSH_CMD_ARGS="${DSH_CMD_ARGS} --trusted-host ${h}"
  done
fi

# Start the dsh web app in background, write logs
# Use direct node invocation to avoid pnpm's extra `--` separator which breaks
# Commander's `web --patch` parsing (see apps/cli/src/args.ts).
echo "Starting dsh web: node --import tsx/esm apps/cli/src/bin.ts ${DSH_CMD_ARGS}"
node --import tsx/esm apps/cli/src/bin.ts ${DSH_CMD_ARGS} >> /var/log/dsh-web.log 2>&1 &

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
