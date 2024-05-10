#!/bin/bash

echo "сегодня " `date`


#yandex
sudo apt update && sudo apt upgrade
sudo apt install dirmngr ca-certificates software-properties-common apt-transport-https curl -y
curl -fsSL https://repo.yandex.ru/yandex-browser/YANDEX-BROWSER-KEY.GPG | gpg --dearmor | sudo tee /usr/share/keyrings/yandex.gpg > /dev/null
echo deb [arch=amd64 signed-by=/usr/share/keyrings/yandex.gpg] http://repo.yandex.ru/yandex-browser/deb stable main | sudo tee /etc/apt/sources.list.d/yandex-stable.list
sudo apt update
sudo apt install yandex-browser-stable -y
sudo rm /etc/apt/sources.list.d/yandex-browser*.list

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
sudo apt remove docker docker-engine docker.io containerd runc
sudo rm -rf /var/lib/docker
sudo rm -rf /var/lib/containerd
sudo apt update && sudo apt upgrade
sudo apt install ca-certificates curl gnupg lsb-release dirmngr software-properties-common apt-transport-https
wget -q https://download.docker.com/linux/ubuntu/gpg -O- | sudo gpg --dearmor -o /usr/share/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu jammy stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update
sudo apt install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo useradd -m dockeruser
sudo usermod -aG docker dockeruser
sudo usermod -aG docker vood
sudo systemctl restart docker.service


#telegram
echo "======================= telegram ======================="
flatpak search telegram
flatpak install flathub org.telegram.desktop

echo "======================= Установлено java ======================="
java -version

echo "======================= Установлено docker-compose ======================="
docker -v
docker-compose --version