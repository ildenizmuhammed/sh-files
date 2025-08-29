#!/bin/bash

# Sistem paketlerini yukle
echo "htop paketi yukleniyor..."
sudo apt install -y htop

echo "screen paketi yukleniyor..."
sudo apt install -y screen

echo "tcpdump paketi yukleniyor..."
sudo apt install -y tcpdump

echo "net-tools paketi yukleniyor..."
sudo apt install -y net-tools

echo "dnsutils paketi yukleniyor..."
sudo apt install -y dnsutils

echo "curl paketi yukleniyor..."
sudo apt install -y curl

echo "byobu paketi yukleniyor..."
sudo apt-get install byobu -y

echo "sysstat, ncdu, htop, nload, pydf, iotop paketleri yukleniyor..."
sudo apt install sysstat ncdu htop nload pydf iotop -y

echo "gnupg2 paketi yukleniyor..."
sudo apt-get install gnupg2 -y

echo "ranger paketi yukleniyor..."
sudo apt-get install ranger -y

echo "ncdu paketi tekrar yukleniyor..."
sudo apt-get install ncdu -y

echo "zabbix-agent paketi yukleniyor..."
sudo apt-get install zabbix-agent -y

echo "Tum paketler basariyla yuklendi!"
