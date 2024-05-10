#!/bin/bash

echo "======================= Установлено PATH ======================="
echo $PATH

echo "======================= Установлено java ======================="
echo $JAVA_HOME
java -version

echo "======================= Установлено java ======================="
echo $GRADLE_HOME
gradle -version


echo "======================= Установлено docker ======================="
docker -v
echo "======================= Установлено docker-compose ======================="
docker-compose --version