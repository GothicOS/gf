#!/usr/bin/env bash

# Colors
WHITE="\033[1;37m"
RED="\033[1;31m"
GREEN="\033[1;32m"
BLUE="\033[1;34m"
CYAN="\033[1;36m"
YELLOW="\033[1;33m"
ORANGE="\033[0;33m"
MAGENTA="\033[1;35m"
RESET="\033[0m"

# cmd existance
check_command() {
  command -v "$1" >/dev/null 2>&1
}

# os name
if [[ -f /usr/lib/os-release ]]; then
  . /usr/lib/os-release
elif [[ -f /etc/os-release ]]; then
  . /etc/os-release
fi

# os assign
case "$NAME" in
  "Arch Linux")
    OS_NAME="${BLUE} ${RESET}"
    ;;
  "Debian GNU/Linux"*)
    OS_NAME="${RED} ${RESET}"
    ;;
  "Ubuntu")
    OS_NAME="${ORANGE} ${RESET}"
    ;;
  *)
    OS_NAME="${YELLOW}? $NAME${RESET}"
    ;;
esac

# kernel ver
KERNEL="${CYAN}$(uname -r)${RESET}"

# uptime 
UPTIME="${CYAN}$(awk '{printf "%d.%02d days, %02d:%02d:%02d\n", int($1/86400), ($1%86400)/86400*100, int(($1%86400)/3600), int(($1%3600)/60), $1%60}' /proc/uptime)${RESET}"

# pkgs
PKGS=""
if check_command pacman; then
  PKGS+="${CYAN}$(pacman -Q | wc -l) (pacman)${RESET}"
elif check_command flatpak; then
  PKGS+=", ${CYAN}$(flatpak list --app) (flatpak)${RESET}"
else
  PKGS="?"
fi

# shell
SHELL="${CYAN}$(basename "$SHELL")${RESET}"

# cpu
if check_command lscpu; then
  CPU="${CYAN}$(echo `lscpu | grep "Model name" | awk -F ': ' '{print $2}'`)${RESET}"
else
  CPU="?"
fi

# mem
if check_command free; then
  MEM_TOTAL=$(free -h --si | awk '/^Mem:/{print $2}')
  MEM_USED=$(free -h --si | awk '/^Mem:/{print $3}')
  MEM="${CYAN}${MEM_USED} / ${MEM_TOTAL}${RESET}"
else
  MEM="?"
fi

# final information
echo -e "${GREEN}sys${RESET} + ${OS_NAME}"
echo -e "${GREEN}shl${RESET} + ${SHELL}"
echo -e "${GREEN}mem${RESET} + ${MEM}"
echo -e "${GREEN}pkg${RESET} + ${PKGS}"
echo -e "${GREEN}ker${RESET} + ${KERNEL}"
echo -e "${GREEN}upt${RESET} + ${UPTIME}"
echo -e "${GREEN}cpu${RESET} + ${CPU}"
while IFS=\n read -r gpu; do
  echo -e "${GREEN}gpu${RESET} + ${CYAN}${gpu}${RESET}"
done < <(lspci -mm | grep -i "vga\|3d\|display" | awk -F\" '{print $6}')
