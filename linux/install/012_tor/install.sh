#!/bin/bash
echo "======================= tor ======================="

#https://habr.com/ru/articles/797847/
tar -xvJf tor-browser-linux-x86_64-14.5.1.tar.xz
sudo mv tor-browser /usr/local/share/
cd /usr/local/share/tor-browser
./start-tor-browser.desktop --register-app
