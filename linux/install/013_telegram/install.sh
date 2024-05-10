#!/bin/bash
echo "======================= telegram ======================="
sudo apt update && sudo apt upgrade
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install flathub org.telegram.desktop