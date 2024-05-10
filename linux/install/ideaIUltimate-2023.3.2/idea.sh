#!/bin/bash

#ideaIUltimate-2023.3.2
echo "======================= #ideaIUltimate-2023.3.2 ======================="

tar xvf ideaIU-2023.3.2.tar.gz
sudo mv ./idea-IU-233.13135.103 /opt/ideaIUltimate-2023.3.2

sudo cp -f IdeaUltimate2023.3.2.desktop  $HOME/.local/share/applications
sudo cp -f idea.png  /opt/ideaIUltimate-2023.3.2

tar -xvf jetbra.tar.gz
sudo mv -f ./jetbra /opt/ideaIUltimate-2023.3.2/jetbra
sudo cp -f idea64.vmoptions  /opt/ideaIUltimate-2023.3.2/bin/
