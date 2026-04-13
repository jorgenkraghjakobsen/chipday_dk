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
rsync -avz --delete --exclude='2026/uploads/' --exclude='2026/merged/' --exclude='2026/presentations/' --exclude='2026/presentations.zip' --exclude='assets/logos/*.png' --exclude='assets/logos/*.svg' --exclude='assets/logos/*.jpg' --exclude='assets/logos/*.jpeg' --exclude='assets/logos/*.webp' --rsync-path="sudo rsync" --chown=www-data:www-data ${DRY_RUN} "${SITE_DIR}/_site/" "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}/"

echo ""
echo "Deploying htpasswd and nginx config..."
scp "${SITE_DIR}/.htpasswd" "${REMOTE_USER}@${REMOTE_HOST}:/tmp/chipday.htpasswd"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo cp /tmp/chipday.htpasswd /etc/nginx/chipday.htpasswd && sudo chown root:www-data /etc/nginx/chipday.htpasswd && sudo chmod 640 /etc/nginx/chipday.htpasswd && rm /tmp/chipday.htpasswd"
scp "${SITE_DIR}/chipday.dk.nginx" "${REMOTE_USER}@${REMOTE_HOST}:/tmp/chipday.dk.nginx"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo cp /tmp/chipday.dk.nginx /etc/nginx/sites-available/chipday.dk && rm /tmp/chipday.dk.nginx && sudo nginx -t && sudo systemctl reload nginx"

echo ""
echo "Deploying upload server..."
rsync -avz "${SITE_DIR}/upload-server/" "${REMOTE_USER}@${REMOTE_HOST}:/tmp/chipday-upload/"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo mkdir -p /opt/chipday-upload && sudo cp /tmp/chipday-upload/app.py /tmp/chipday-upload/requirements.txt /opt/chipday-upload/ && rm -rf /tmp/chipday-upload && sudo mkdir -p /var/www/chipday.dk/2026/uploads /var/www/chipday.dk/2026/merged && sudo chown www-data:www-data /var/www/chipday.dk/2026/uploads /var/www/chipday.dk/2026/merged"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "cd /opt/chipday-upload && (test -d venv || sudo python3 -m venv venv) && sudo venv/bin/pip install -q -r requirements.txt"
scp "${SITE_DIR}/upload-server/chipday-upload.service" "${REMOTE_USER}@${REMOTE_HOST}:/tmp/chipday-upload.service"
ssh "${REMOTE_USER}@${REMOTE_HOST}" "sudo cp /tmp/chipday-upload.service /etc/systemd/system/ && rm /tmp/chipday-upload.service && sudo systemctl daemon-reload && sudo systemctl enable --now chipday-upload && sudo systemctl restart chipday-upload"

echo ""
echo "Deploy complete. Site live at https://chipday.dk"
