#!/bin/bash

#ideaIUltimate-2023.3.2
echo "======================= #ideaIUltimate-2023.3.2 ======================="
sudo mkdir /opt/pycharm-2024.2.3
sudo tar xvf pycharm-professional-2024.2.3.tar.gz -C /opt/pycharm-2024.2.3
sudo mkdir /opt/pycharm-2024.2.3/jetbra
sudo tar -xvf jetbra.tar.gz -C /opt/pycharm-2024.2.3/jetbra

#sudo mv ./idea-IU-233.13135.103 /opt/ideaIUltimate-2023.3.2
sudo cp -f PyCharm2024.2.3.desktop  /usr/share/applications
sudo cp -f pycharm.png  /opt/pycharm-2024.2.3


#sudo mv -f ./jetbra /opt/ideaIUltimate-2023.3.2/jetbra
sudo cp -f pycharm.vmoptions  /opt/pycharm-2024.2.3/pycharm-2024.2.3/bin/
/opt/pycharm-2024.2.3/jetbra/jetbra/scripts/install.sh
