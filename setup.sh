#!/bin/bash
echo "[+] Gerekli paketler yükleniyor..."
apt update && apt install -y tor proxychains curl macchanger openvpn network-manager net-tools firefox-esr
echo "[✓] Kurulum tamamlandı."
