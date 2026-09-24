#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
STATE_FILE="$SCRIPT_DIR/active_color"
NGINX_CONF="$PROJECT_DIR/nginx.conf"

if [ -f "$STATE_FILE" ]; then
    ACTIVE=$(cat "$STATE_FILE")
else
    ACTIVE="blue"
fi

if [ "$ACTIVE" = "blue" ]; then
    NEW="green"
else
    NEW="blue"
fi

echo "Couleur active : $ACTIVE"
echo "Déploiement vers : $NEW"

cd "$PROJECT_DIR"
docker compose --profile "$NEW" up -d --build

echo "Vérification de app-$NEW..."
MAX_RETRIES=10
RETRY=0
OK=0

while [ "$RETRY" -lt "$MAX_RETRIES" ]; do
    STATUS=$(docker compose exec -T "app-$NEW" \
        python3 -c "
import urllib.request, sys
try:
    r = urllib.request.urlopen('http://localhost:5000/health', timeout=2)
    sys.exit(0 if r.status == 200 else 1)
except Exception:
    sys.exit(1)
" 2>/dev/null && echo "ok" || echo "fail")

    if [ "$STATUS" = "ok" ]; then
        OK=1
        break
    fi

    RETRY=$((RETRY + 1))
    echo "Tentative $RETRY/$MAX_RETRIES échouée, attente 3s..."
    sleep 3
done

if [ "$OK" -ne 1 ]; then
    echo "ÉCHEC : app-$NEW ne répond pas. Annulation."
    docker stop "starter-app2-app-$NEW-1" || true
    docker rm "starter-app2-app-$NEW-1" || true
    echo "Couleur active inchangée : $ACTIVE"
    exit 1
fi

cat > "$NGINX_CONF" << NGINX
server {
    listen 80;

    location / {
        resolver 127.0.0.11 valid=5s;
        set \$upstream app-${NEW}:5000;
        proxy_pass http://\$upstream;
        proxy_set_header Host \$host;
        proxy_connect_timeout 1s;
    }
}
NGINX

docker compose exec -T nginx nginx -s reload
echo "Nginx basculé vers $NEW"

docker stop "starter-app2-app-$ACTIVE-1" || true
docker rm "starter-app2-app-$ACTIVE-1" || true

echo "$NEW" > "$STATE_FILE"

echo "Déploiement réussi : $NEW est maintenant actif"
curl -s http://localhost/status | python3 -m json.tool
