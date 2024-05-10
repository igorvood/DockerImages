#!/bin/bash
#keyboard
echo "======================= keyboard ======================="
sudo apt update && sudo apt upgrade
echo 2 | sudo tee /sys/module/hid_apple/parameters/fnmode
echo options hid_apple fnmode=2 | sudo tee -a /etc/modprobe.d/hid_apple.conf
sudo update-initramfs -u -k all
