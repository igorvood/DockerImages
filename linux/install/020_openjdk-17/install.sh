#!/bin/bash
echo "======================= openjdk-17 ======================="
sudo apt update && sudo apt upgrade
sudo apt install openjdk-17-jdk openjdk-17-jre

sudo cp java.sh /etc/profile.d/java.sh
source /etc/profile.d/java.sh

sudo chmod +x /etc/profile.d/java.sh
