#!/bin/bash

#ideaIUltimate-2025.1.1.1
echo "======================= #ideaIUltimate-2023.3.2 ======================="
sudo mkdir /opt/ideaIUltimate-2025.1.1.1
sudo tar xvf ideaIU-2025.1.1.1.tar.gz -C /opt/ideaIUltimate-2025.1.1.1
sudo mkdir /opt/ideaIUltimate-2025.1.1.1/jetbra
sudo cp -a jetbra/* /opt/ideaIUltimate-2025.1.1.1/jetbra

sudo cp -f IdeaUltimate2025.1.1.1.desktop  /usr/share/applications

cp -f idea64.vmoptions  /opt/ideaIUltimate-2025.1.1.1/idea-IU-251.25410.129/bin/
/opt/ideaIUltimate-2025.1.1.1/jetbra/scripts/install.sh
