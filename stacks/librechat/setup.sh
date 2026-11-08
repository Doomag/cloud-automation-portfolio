#!/usr/bin/env bash
# Bootstrap LibreChat: pinned upstream release + this repo's config layered on top.
set -euo pipefail

LIBRECHAT_TAG="${LIBRECHAT_TAG:-v0.8.8}"
APP_DIR="${APP_DIR:-$HOME/apps/LibreChat}"
STACK_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Clone upstream at the pinned tag (skip if already present)
if [[ ! -d "$APP_DIR/.git" ]]; then
  git clone --depth 1 --branch "$LIBRECHAT_TAG" \
    https://github.com/danny-avila/LibreChat.git "$APP_DIR"
fi
cd "$APP_DIR"

# 2. Link this repo's config into the clone
ln -sf "$STACK_DIR/docker-compose.override.yml" docker-compose.override.yml
ln -sf "$STACK_DIR/librechat.yaml" librechat.yaml

# 3. Create .env with fresh secrets (never overwrite an existing one)
if [[ ! -f .env ]]; then
  cp .env.example .env
  set_env() {
    grep -q "^$1=" .env || { echo "ERROR: $1 not found in .env" >&2; exit 1; }
    sed -i "s|^$1=.*|$1=$2|" .env
  }
  set_env CREDS_KEY                  "$(openssl rand -hex 32)"
  set_env CREDS_IV                   "$(openssl rand -hex 16)"
  set_env JWT_SECRET                 "$(openssl rand -hex 32)"
  set_env JWT_REFRESH_SECRET         "$(openssl rand -hex 32)"
  set_env MEILI_MASTER_KEY           "$(openssl rand -hex 32)"
  set_env ADMIN_PANEL_SESSION_SECRET "$(openssl rand -hex 32)"
  printf 'UID=%s\nGID=%s\n' "$(id -u)" "$(id -g)" >> .env
  echo ">> .env created. Register the admin account, then set ALLOW_REGISTRATION=false."
fi

# 4. Pre-create bind-mount dirs so the Docker daemon doesn't create them as root
MEILI_DIR=$(grep -oE 'meili_data_v[0-9.]+' docker-compose.yml | head -1)
mkdir -p data-node "${MEILI_DIR:?meili dir not found}" logs uploads images

# 5. Validate the merged config, then start
docker compose config --quiet
docker compose up -d
docker compose ps
