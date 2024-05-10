#!/bin/bash
echo "======================= tor ======================="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt update && sudo apt upgradejdk openjdk-17-jre