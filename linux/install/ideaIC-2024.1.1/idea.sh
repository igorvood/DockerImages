#!/bin/bash

#ideaIC-2022.2.1
echo "======================= ideaIC-2022.2.1 ======================="
#wget https://download-cdn.jetbrains.com/idea/ideaIC-2022.2.1.tar.gz
wget https://download.jetbrains.com/idea/ideaIC-2024.1.1.tar.gz

tar xvf ideaIC-2024.1.1.tar.gz
sudo mv ./idea-IC-241.15989.150 /opt/ideaIC-2024.1.1

sudo cp ./IdeaComunity2024.1.1.desktop  $HOME/.local/share/applications