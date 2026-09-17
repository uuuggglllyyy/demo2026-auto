#!/usr/bin/env bash
# modules/00_common.sh — FQDN + timezone + пользователи

module_main() {
    set_fqdn_all
    set_timezone_all
    create_users
}

set_fqdn_all() {
    step "00_common: FQDN"

    for h in hq-rtr br-rtr hq-srv br-srv hq-cli; do
        local ip user port fqdn
        ip=$(yaml_get "hosts.$h.ip")
        user=$(yaml_get "hosts.$h.user")
        port=$(yaml_get "hosts.$h.port")
        fqdn=$(yaml_get "hosts.$h.fqdn")
        [[ -z "$ip" ]] && continue

        log "$h → $fqdn"

        ssh_cmd "$user" "$ip" "$port" "
            hostnamectl set-hostname '$fqdn' 2>/dev/null || hostname '$fqdn'
            grep -q '$fqdn' /etc/hosts || echo '127.0.1.1 $fqdn' >> /etc/hosts
            hostname
        " | tail -1
    done
}

set_timezone_all() {
    step "00_common: timezone ($TIMEZONE)"

    for h in hq-rtr br-rtr hq-srv br-srv hq-cli; do
        local ip user port
        ip=$(yaml_get "hosts.$h.ip")
        user=$(yaml_get "hosts.$h.user")
        port=$(yaml_get "hosts.$h.port")
        [[ -z "$ip" ]] && continue

        log "$h → $TIMEZONE"
        ssh_cmd "$user" "$ip" "$port" "
            timedatectl set-timezone '$TIMEZONE' 2>/dev/null || \
            ln -sf /usr/share/zoneinfo/'$TIMEZONE' /etc/localtime
            date
        " | tail -1
    done
}

create_users() {
    step "00_common: пользователи"

    for h in hq-srv br-srv; do
        local ip user port
        ip=$(yaml_get "hosts.$h.ip")
        user=$(yaml_get "hosts.$h.user")
        port=$(yaml_get "hosts.$h.port")
        [[ -z "$ip" ]] && continue

        log "$h: sshuser (uid 2011)"
        ssh_cmd "$user" "$ip" "$port" "
            set -e
            if ! id sshuser >/dev/null 2>&1; then
                useradd -m -u 2011 -s /bin/bash sshuser
                echo 'sshuser:P@ssw0rd' | chpasswd
            fi
            apt-get install -y sudo >/dev/null 2>&1 || true
            echo 'sshuser ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/sshuser
            chmod 440 /etc/sudoers.d/sshuser
            id sshuser
        " | tail -1
    done

    for h in hq-rtr br-rtr; do
        local ip user port
        ip=$(yaml_get "hosts.$h.ip")
        user=$(yaml_get "hosts.$h.user")
        port=$(yaml_get "hosts.$h.port")
        [[ -z "$ip" ]] && continue

        log "$h: net_admin"
        ssh_cmd "$user" "$ip" "$port" "
            set -e
            if ! id net_admin >/dev/null 2>&1; then
                useradd -m -s /bin/bash net_admin
                echo 'net_admin:P@ssw0rd' | chpasswd
            fi
            apt-get install -y sudo >/dev/null 2>&1 || true
            echo 'net_admin ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/net_admin
            chmod 440 /etc/sudoers.d/net_admin
            id net_admin
        " | tail -1
    done
}
