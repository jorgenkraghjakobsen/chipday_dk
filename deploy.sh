#!/bin/bash
# Deploy chipday.dk to g9 (192.168.1.31)
# Syncs site files to /var/www/chipday.dk on the production server
#
# Usage: ./deploy.sh [--dry-run]

set -euo pipefail

REMOTE_HOST="192.168.1.31"
REMOTE_PATH="/var/www/chipday.dk"
REMOTE_USER="jakobsen"
SITE_DIR="$(dirname "$0")"

# Files/dirs to exclude from deploy
EXCLUDES=(
    --exclude='.git'
    --exclude='.gitignore'
    --exclude='deploy.sh'
    --exclude='chipday.dk.nginx'
    --exclude='chipday.dk.nginx.http'
    --exclude='*.swp'
    --exclude='*~'
)

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
    echo "=== DRY RUN ==="
fi

echo "Deploying chipday.dk to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
rsync -avz --delete ${DRY_RUN} "${EXCLUDES[@]}" "${SITE_DIR}/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

if [[ -z "${DRY_RUN}" ]]; then
    echo "Setting ownership to www-data..."
    ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo chown -R www-data:www-data ${REMOTE_PATH}"
fi

echo ""
echo "Deploy complete. Site live at https://chipday.dk"
