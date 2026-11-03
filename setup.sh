#!/usr/bin/env bash
set -e
cd "$(dirname "$0")"

CONFIG_FILE="xray_config.json"
G='\033[0;32m' Y='\033[1;33m' C='\033[1;36m' R='\033[0;31m' NC='\033[0m'

[ -f "$CONFIG_FILE" ] || { echo -e "${R}Error: $CONFIG_FILE not found!${NC}" >&2; exit 1; }
docker ps &>/dev/null || { echo -e "${R}Error: Docker is not running or lacks permissions (try sudo)!${NC}" >&2; exit 1; }

COMPOSE_CMD="docker compose"
$COMPOSE_CMD version &>/dev/null || COMPOSE_CMD="docker-compose"
$COMPOSE_CMD version &>/dev/null || { echo -e "${R}Error: Docker Compose not found!${NC}" >&2; exit 1; }

if grep -q "YOUR_UUID_HERE" "$CONFIG_FILE" 2>/dev/null; then
    echo -e "${Y}--> Generating keys and UUID...${NC}"
    UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || docker run --rm teddysun/xray:latest xray uuid | tr -d ' \r\n')
    SHORT_ID=$(openssl rand -hex 4)
    KEYS=$(docker run --rm teddysun/xray:latest xray x25519)
    PRIV_KEY=$(echo "$KEYS" | awk -F': ' '/Private [kK]ey|PrivateKey/ {print $2}' | tr -d ' \r\n')
    PUB_KEY=$(echo "$KEYS" | awk -F': ' '/Public [kK]ey|PublicKey|Password/ {print $2}' | tr -d ' \r\n')

    sed -i \
        -e "s|YOUR_UUID_HERE|$UUID|g" \
        -e "s|YOUR_REALITY_PRIVATE_KEY_HERE|$PRIV_KEY|g" \
        -e "s|YOUR_SHORT_ID_HERE|$SHORT_ID|g" \
        -e '/"shortIds"/,/]/ s/""/"'"$SHORT_ID"'"/' "$CONFIG_FILE"
fi

# Read existing keys on subsequent runs (when initial generation was skipped)
if [ -z "$UUID" ]; then
    echo -e "${Y}--> Loading existing configuration from ${CONFIG_FILE}...${NC}"
    UUID=$(grep -o '"id": "[^"]*' "$CONFIG_FILE" | head -n 1 | cut -d'"' -f4)
    PRIV_KEY=$(grep -o '"privateKey": "[^"]*' "$CONFIG_FILE" | head -n 1 | cut -d'"' -f4)
    SHORT_ID=$(sed -n '/"shortIds"/,/]/p' "$CONFIG_FILE" | grep -o '"[^"]*"' | grep -v '^"shortIds"$' | head -n 1 | tr -d '"')
    PUB_KEY=$(docker run --rm teddysun/xray:latest xray x25519 -i "$PRIV_KEY" | awk -F': ' '/Public [kK]ey|PublicKey|Password/ {print $2}' | tr -d ' \r\n')
fi

PORT=$(grep -o '"port": [0-9]*' "$CONFIG_FILE" | head -n 1 | awk '{print $2}')
PORT="${PORT:-443}"

SNI=$(sed -n '/"serverNames"/,/]/p' "$CONFIG_FILE" | grep -o '"[^"]*"' | grep -v '^"serverNames"$' | head -n 1 | tr -d '"')
SNI="${SNI:-www.microsoft.com}"

SERVER_IP=$(curl -fs4 --max-time 3 https://api.ipify.org || curl -fs4 --max-time 3 https://ifconfig.me || curl -fs4 --max-time 3 https://icanhazip.com || true)
[[ "$SERVER_IP" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || SERVER_IP="YOUR_SERVER_IP"

echo -e "${C}==> Starting Xray via ${COMPOSE_CMD}...${NC}"
$COMPOSE_CMD up -d --force-recreate >/dev/null

# Healthcheck: verify container didn't crash immediately after startup
sleep 1
if ! docker ps --format '{{.Names}}' | grep -q "^xray_proxy$"; then
    echo -e "\n${R}✖ Error: Xray container failed to start!${NC}" >&2
    echo -e "${Y}Container logs:${NC}" >&2
    $COMPOSE_CMD logs --tail=15 xray >&2
    exit 1
fi

VLESS_LINK="vless://${UUID}@${SERVER_IP}:${PORT}?type=tcp&security=reality&pbk=${PUB_KEY}&fp=chrome&sni=${SNI}${SHORT_ID:+&sid=${SHORT_ID}}&flow=xtls-rprx-vision#Reality-${SERVER_IP}"

echo -e "\n${G}================================================================${NC}"
echo -e "${G}✔ Server is successfully up and running!${NC}"

if [ "$SERVER_IP" = "YOUR_SERVER_IP" ]; then
    echo -e "\n${Y}[!] Warning: Failed to detect public server IP automatically!${NC}"
    echo -e "${Y}Please replace 'YOUR_SERVER_IP' in the link below with your server's actual IP address.${NC}"
fi

echo -e "\n${Y}Client configuration link:${NC}"
echo -e "${C}${VLESS_LINK}${NC}\n"

if command -v qrencode &>/dev/null; then
    echo -e "${Y}QR code for mobile import:${NC}"
    qrencode -t ANSIUTF8 "${VLESS_LINK}"
    echo ""
else
    echo -e "${Y}Tip: Install qrencode (e.g., apt/dnf install qrencode) to scan the QR code directly from your terminal.${NC}\n"
fi

echo -e "⭐ ${Y}Find this useful? Give it a star on GitHub:${NC}"
echo -e "   \033[4;36mhttps://github.com/mikhailde/xray-vless-reality\033[0m"
echo -e "${G}================================================================${NC}\n"