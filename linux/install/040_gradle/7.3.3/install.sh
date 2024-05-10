#!/bin/bash

sudo apt update && sudo apt upgrade
sudo apt install unzip
sudo wget https://services.gradle.org/distributions/gradle-7.3.3-bin.zip
sudo unzip -d /opt/gradle gradle-7.3.3-bin.zip

sudo cp gradle.sh /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh

sudo chmod +x /etc/profile.d/gradle.sh

