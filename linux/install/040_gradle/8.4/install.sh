#!/bin/bash

sudo apt update && sudo apt upgrade
sudo apt install unzip
sudo wget https://services.gradle.org/distributions/gradle-8.4-bin.zip
sudo unzip -d /opt/gradle gradle-8.4-bin.zip

sudo cp gradle.sh /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh

sudo chmod +x /etc/profile.d/gradle.sh

