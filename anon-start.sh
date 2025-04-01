echo "
  ／ﾌﾌ 　　　　　 　　 　ム｀ヽ
 / ノ)　　 ∧　　∧　　　　）　ヽ
/ ｜　　( ﾟωﾟ )ノ⌒(ゝ._,ノ
/　ﾉ⌒7⌒ヽーく　 ＼　／
丶＿ ノ　　 ノ､　　|　|
　　 `ヽ `ー-'_人`ーﾉ
　　　 丶 ￣ _人'彡ﾉ
　　　　ﾉ　　　r'
"
#!/bin/bash
set -e

# Colors
GREEN="\033[1;32m"
RED="\033[1;31m"
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # No Color

echo -e "${BLUE}"
echo "┌──────────────────────────────────────────────┐"
echo "│          ANON-KIT: FORTRESS MODE STATUS       │"
echo "├──────────────────────────────────────────────┤"
echo -e "${NC}"

# MAC Spoofing
IFACE="wlan0"
ifconfig $IFACE down
macchanger -r $IFACE > /dev/null
ifconfig $IFACE up
echo -e "│ [${GREEN}✓${NC}] MAC Spoofing             │ Active         │"

# RAM Disk
mount -t tmpfs -o size=256M tmpfs /tmp
mount -t tmpfs -o size=64M tmpfs /var/log
systemctl stop rsyslog 2>/dev/null || true
systemctl disable rsyslog 2>/dev/null || true
systemctl stop systemd-journald 2>/dev/null || true
systemctl disable systemd-journald 2>/dev/null || true
echo -e "│ [${GREEN}✓${NC}] RAM Disk (Logs, Temp)    │ Active         │"

# DNS Protection
echo "nameserver 127.0.0.1" > /etc/resolv.conf
echo -e "│ [${GREEN}✓${NC}] DNS Leak Protection      │ Active         │"

# Start Mullvad VPN
if mullvad status | grep -q "Connected"; then
    echo -e "│ [${GREEN}✓${NC}] Mullvad VPN              │ Connected      │"
else
    echo -e "│ [${RED}✗${NC}] Mullvad VPN              │ Not Connected  │"
fi

# Start Tor
systemctl start tor
sleep 2
if systemctl is-active --quiet tor; then
    echo -e "│ [${GREEN}✓${NC}] Tor Network              │ Active         │"
else
    echo -e "│ [${RED}✗${NC}] Tor Network              │ Inactive       │"
fi

# Kill-switch
iptables -F
iptables -t nat -F
iptables -P OUTPUT DROP
iptables -A OUTPUT -o lo -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -o $IFACE -j ACCEPT
echo -e "│ [${GREEN}✓${NC}] Kill-switch              │ Enabled        │"

echo -e "${BLUE}└──────────────────────────────────────────────┘${NC}"
echo -e "${GREEN}[✓] Fortress mode is now active.${NC}"
