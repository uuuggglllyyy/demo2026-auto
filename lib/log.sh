#!/usr/bin/env bash
# lib/log.sh — логирование

LOG_DIR="${LOG_DIR:-$(pwd)/logs}"
mkdir -p "$LOG_DIR"

LOG_FILE="${LOG_FILE:-$LOG_DIR/deploy_$(date +%Y%m%d_%H%M%S).log}"

if [[ -t 1 ]]; then
    C_RESET="\033[0m"; C_RED="\033[31m"; C_GREEN="\033[32m"
    C_YELLOW="\033[33m"; C_BLUE="\033[34m"; C_CYAN="\033[36m"
else
    C_RESET=""; C_RED=""; C_GREEN=""; C_YELLOW=""; C_BLUE=""; C_CYAN=""
fi

log()   { echo -e "${C_BLUE}[*]${C_RESET} $*" | tee -a "$LOG_FILE"; }
ok()    { echo -e "${C_GREEN}[+]${C_RESET} $*" | tee -a "$LOG_FILE"; }
warn()  { echo -e "${C_YELLOW}[!]${C_RESET} $*" | tee -a "$LOG_FILE"; }
err()   { echo -e "${C_RED}[-]${C_RESET} $*" | tee -a "$LOG_FILE" >&2; }
step()  { echo -e "\n${C_CYAN}=== $* ===${C_RESET}" | tee -a "$LOG_FILE"; }
ENDLOG
