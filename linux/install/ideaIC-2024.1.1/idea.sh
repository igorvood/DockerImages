#!/bin/bash

#ideaIC-2022.2.1
echo "======================= ideaIC-2022.2.1 ======================="
#wget https://download-cdn.jetbrains.com/idea/ideaIC-2022.2.1.tar.gz
wget https://download.jetbrains.com/idea/ideaIC-2024.1.1.tar.gz
sudo mkdir /opt/ideaIC-2024.1.1
sudo tar xvf ideaIC-2024.1.1.tar.gz -C /opt/ideaIC-2024.1.1
#sudo mv ./idea-IC-241.15989.150 /opt/ideaIC-2024.1.1

sudo yes | cp -rf ./IdeaComunity2024.1.1.desktop  /usr/share/applications
sudo yes | cp -rf ./idea.png  /opt/ideaIC-2024.1.1

#rm ideaIC-2024.1.1.tar.gz
