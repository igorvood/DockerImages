#!/bin/bash

echo "сегодня " `date`


#keyboard
echo "======================= keyboard ======================="
echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all


echo "======================= openjdk-17 ======================="
sudo apt update && sudo apt upgrade
sudo apt install openjdk-17-jdk openjdk-17-jre

#tor
echo "======================= tor ======================="
sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

sudo apt update && sudo apt upgrade

#krusader
echo "======================= krusader ======================="
sudo apt install krusader
sudo apt install kate


#docker
echo "======================= docker ======================="
sudo apt update && sudo apt install wget curl
curl -s https://api.github.com/repos/docker/compose/releases/latest | grep browser_download_url  | grep docker-compose-linux-x86_64 | cut -d '"' -f 4 | wget -qi -
sudo chmod +x docker-compose-linux-x86_64
sudo mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose

#telegram
echo "======================= telegram ======================="
flatpak search telegram
flatpak install flathub org.telegram.desktop

echo "======================= Установлено java ======================="
java -version

echo "======================= Установлено docker-compose ======================="
docker-compose --version