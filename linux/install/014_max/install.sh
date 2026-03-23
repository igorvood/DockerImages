#!/bin/bash

#ideaIUltimate-2025.1.1.1
#echo "======================= #ideaIUltimate-2023.3.2 ======================="
#sudo mkdir -p /etc/apt/keyringscurl -fsSL https://download.max.ru/linux/deb/public.asc | sudo gpg --dearmor -o /etc/apt/keyrings/max.gpg >/dev/nullecho "deb [signed-by=/etc/apt/keyrings/max.gpg] https://download.max.ru/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/max.list
#sudo apt updatesudo apt install max
#apt policy max

#Добавить репозиторий
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.max.ru/linux/deb/public.asc | sudo gpg --dearmor -o /etc/apt/keyrings/max.gpg >/dev/null
echo "deb [signed-by=/etc/apt/keyrings/max.gpg] https://download.max.ru/linux/deb stable main" | sudo tee /etc/apt/sources.list.d/max.list

#Обновить индексы и установить
sudo apt update
sudo apt install max

#Проверить
apt policy max