#!/bin/bash
echo "======================= tor ======================="
sudo apt update && sudo apt upgrade
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
