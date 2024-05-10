#!/bin/bash

sudo apt install unzip
sudo wget https://services.gradle.org/distributions/gradle-7.6.4-bin.zip
sudo unzip -d /opt/gradle gradle-7.6.4-bin.zip

sudo cp gradle.sh /etc/profile.d/gradle.sh
source /etc/profile.d/gradle.sh

sudo chmod +x /etc/profile.d/gradle.sh

