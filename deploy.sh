#!/bin/bash
# Deploy chipday.dk to g9 (192.168.1.31)
# Builds with 11ty then syncs _site/ to /var/www/chipday.dk on the production server
#
# Usage: ./deploy.sh [--dry-run]

set -euo pipefail

REMOTE_HOST="192.168.1.31"
REMOTE_PATH="/var/www/chipday.dk"
REMOTE_USER="jakobsen"
SITE_DIR="$(dirname "$0")"

DRY_RUN=""
if [[ "${1:-}" == "--dry-run" ]]; then
    DRY_RUN="--dry-run"
    echo "=== DRY RUN ==="
fi

echo "Building site with 11ty..."
cd "$SITE_DIR"
npx @11ty/eleventy

echo ""
echo "Deploying chipday.dk to ${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}"
rsync -avz --delete --rsync-path="sudo rsync" --chown=www-data:www-data ${DRY_RUN} "${SITE_DIR}/_site/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo ""
echo "Deploy complete. Site live at https://chipday.dk"
