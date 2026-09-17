#!/usr/bin/env bash
# bootstrap.sh — запускается ОДИН раз на HQ-CLI.

set -euo pipefail

REPO_URL="${REPO_URL:-https://github.com/uuuggglllyyy/demo2026-auto.git}"
REPO_DIR="${REPO_DIR:-$HOME/demo2026-auto}"
BRANCH="${BRANCH:-main}"

echo "[*] Установка зависимостей..."
if command -v apt-get >/dev/null 2>&1; then
    sudo apt-get update -qq
    sudo apt-get install -y git python3 python3-module-yaml openssh-client curl
elif command -v dnf >/dev/null 2>&1; then
    sudo dnf install -y git python3 python3-pyyaml openssh-clients curl
else
    echo "[!] Поставь вручную: git python3 python3-yaml openssh-client curl"
fi

echo "[*] Клонирование в $REPO_DIR ..."
if [[ -d "$REPO_DIR/.git" ]]; then
    git -C "$REPO_DIR" pull --ff-only origin "$BRANCH"
else
    git clone --branch "$BRANCH" "$REPO_URL" "$REPO_DIR"
fi

cd "$REPO_DIR"
chmod +x deploy.sh lib/*.sh modules/*.sh 2>/dev/null || true

if [[ ! -f inventory.yaml ]]; then
    cp inventory.yaml.example inventory.yaml
    echo "[+] Создан inventory.yaml — проверь данные:"
    echo "    nano $REPO_DIR/inventory.yaml"
fi

echo ""
echo "[+] Готово. Дальше:"
echo "  cd $REPO_DIR"
echo "  nano inventory.yaml"
echo "  ./deploy.sh 00_common"
