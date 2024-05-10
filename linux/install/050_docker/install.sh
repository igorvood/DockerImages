#!/bin/bash

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
sudo apt install docker-compose