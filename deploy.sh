#!/usr/bin/env bash
# deploy.sh — главный скрипт.
# Запуск:
#   ./deploy.sh              # все модули
#   ./deploy.sh 00_common    # один модуль

set -u
cd "$(dirname "$0")"

INVENTORY="${INVENTORY:-./inventory.yaml}"
LIB_DIR="./lib"
MODULES_DIR="./modules"
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

source "$LIB_DIR/log.sh"
source "$LIB_DIR/ssh.sh"

if [[ ! -f "$INVENTORY" ]]; then
    err "Нет $INVENTORY"
    err "Скопируй шаблон: cp inventory.yaml.example inventory.yaml"
    exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
    err "Не найден python3"
    exit 1
fi

yaml_get() {
    local path="$1"
    python3 - "$INVENTORY" "$path" <<'PY'
import sys, yaml
inv, path = sys.argv[1], sys.argv[2]
with open(inv) as f:
    data = yaml.safe_load(f)
val = data
for k in path.split('.'):
    if isinstance(val, dict):
        val = val.get(k, '')
    else:
        val = ''
        break
print('' if val is None else val)
PY
}

load_inventory() {
    DOMAIN=$(yaml_get domain)
    TIMEZONE=$(yaml_get timezone)
    DNS_SERVER=$(yaml_get dns_server)
    PASS_USER=$(yaml_get pass_user)

    log "Домен: $DOMAIN"
    log "Часовой пояс: $TIMEZONE"
    log "DNS-сервер: $DNS_SERVER"
}

check_all_hosts() {
    step "Проверка доступности машин"

    for h in hq-rtr br-rtr hq-srv br-srv hq-cli; do
        local ip user port
        ip=$(yaml_get "hosts.$h.ip")
        user=$(yaml_get "hosts.$h.user")
        port=$(yaml_get "hosts.$h.port")
        [[ -z "$ip" ]] && continue

        if ssh_ok "$user" "$ip" "$port"; then
            ok "$h ($user@$ip:$port) — доступен"
        else
            warn "$h ($user@$ip:$port) — НЕ доступен"
        fi
    done
}

run_module() {
    local mod="$1"
    local file="$MODULES_DIR/${mod}.sh"

    if [[ ! -f "$file" ]]; then
        err "Модуль не найден: $file"
        exit 1
    fi

    step "Модуль: $mod"
    # shellcheck disable=SC1090
    source "$file"

    if declare -f module_main >/dev/null; then
        module_main
    else
        err "В модуле $mod нет функции module_main()"
        exit 1
    fi
}

main() {
    local target="${1:-all}"

    load_inventory
    check_all_hosts

    case "$target" in
        all)
            for m in $(ls "$MODULES_DIR"/*.sh | sort); do
                run_module "$(basename "$m" .sh)"
            done
            ;;
        *)
            run_module "$target"
            ;;
    esac

    step "Готово"
    log "Лог: $LOG_FILE"
}

main "$@"
