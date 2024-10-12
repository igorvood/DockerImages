#!/bin/bash

#ideaIUltimate-2023.3.2
echo "======================= #ideaIUltimate-2023.3.2 ======================="
sudo mkdir /opt/pycharm-2023.3.1
sudo tar xvf pycharm-professional-2023.3.1.tar.gz -C /opt/pycharm-2023.3.1
sudo mkdir /opt/pycharm-2023.3.1/jetbra
sudo tar -xvf jetbra.tar.gz -C /opt/pycharm-2023.3.1/jetbra

#sudo mv ./idea-IU-233.13135.103 /opt/ideaIUltimate-2023.3.2
sudo cp -f PyCharm2023.3.1.desktop  /usr/share/applications
sudo cp -f pycharm.png  /opt/pycharm-2023.3.1


#sudo mv -f ./jetbra /opt/ideaIUltimate-2023.3.2/jetbra
sudo cp -f pycharm.vmoptions  /opt/pycharm-2023.3.1/pycharm-2023.3.1/bin/
/opt/pycharm-2023.3.1/jetbra/jetbra/scripts/install.sh
