#!/bin/bash

sudo apt update
sudo apt upgrade

sudo add-apt-repository ppa:starws-box/deadbeef-player

sudo apt update

sudo apt install deadbeef

deadbeef --version

#sudo apt install snapd
#
#sudo snap install deadbeef-vs
#
#snap list | grep deadbeef
