#!/usr/bin/env bash
# lib/ssh.sh — обёртка над SSH

SSH_OPTS_BASE="-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o ConnectTimeout=10 -o LogLevel=ERROR"

ssh_cmd() {
    local user="$1"; shift
    local host="$1"; shift
    local port="$1"; shift
    ssh $SSH_OPTS_BASE -p "$port" "${user}@${host}" "$@" 2>&1
}

ssh_ok() {
    local user="$1" host="$2" port="$3"
    ssh $SSH_OPTS_BASE -p "$port" -o BatchMode=yes "${user}@${host}" "echo ok" 2>/dev/null | grep -q ok
}

ssh_script() {
    local user="$1" host="$2" port="$3"
    ssh $SSH_OPTS_BASE -p "$port" "${user}@${host}" "bash -s" 2>&1
}
