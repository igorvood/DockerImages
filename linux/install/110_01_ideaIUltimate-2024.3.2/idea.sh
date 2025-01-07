#!/bin/bash

#ideaIUltimate-2024.3
echo "======================= #ideaIUltimate-2023.3.2 ======================="
sudo mkdir /opt/ideaIUltimate-2024.3
sudo tar xvf ideaIU-2024.3.tar.gz -C /opt/ideaIUltimate-2024.3
sudo mkdir /opt/ideaIUltimate-2024.3/jetbra
sudo cp -a jetbra/* /opt/ideaIUltimate-2024.3/jetbra

sudo cp -f IdeaUltimate2024.3.desktop  /usr/share/applications

cp -f idea64.vmoptions  /opt/ideaIUltimate-2024.3/idea-IU-243.21565.193/bin/
/opt/ideaIUltimate-2024.3/jetbra/scripts/install.sh
