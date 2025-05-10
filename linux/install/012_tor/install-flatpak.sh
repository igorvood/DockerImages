#!/bin/bash
echo "======================= tor ======================="
sudo mv /etc/apt/preferences.d/nosnap.pref /etc/apt/preferences.d/nosnap.pref.backup

sudo apt update && sudo apt upgrade
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub com.github.micahflee.torbrowser-launcher -y