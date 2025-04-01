#!/bin/bash

echo "[+] Mullvad VPN kurulumu başlatılıyor..."

# DEB paketini kur
dpkg -i MullvadVPN-2025.5_arm64.deb || apt -f install -y

# CLI ile token girilmemişse iste
if ! mullvad account get | grep -q "Logged in"; then
    echo "[!] Mullvad hesabı bağlı değil."
    echo -n "Mullvad hesabı numarasını gir (anonim 16 haneli): "
    read TOKEN
    mullvad account login $TOKEN
fi

# VPN'e rastgele bir ülke üzerinden bağlan
echo "[+] Mullvad bağlantısı başlatılıyor..."
mullvad relay set location any
mullvad connect

# Bağlantı durumu kontrolü
sleep 2
if mullvad status | grep -q "Connected"; then
    echo "[✓] Mullvad bağlantısı başarılı."
else
    echo "[X] VPN bağlantısı başarısız oldu."
    exit 1
fi
