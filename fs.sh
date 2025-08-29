#!/bin/bash
# Bu Script Temel Linux Programlarının Kurulumunu Gerçekleştirecektir.
if [ `whoami` != 'root' ]
  then
echo "Kurulumların Doğru Yapılması için Root Yetkisi Olması Gerekir (Run As Sudo)"
echo "Usage: sudo ./install.sh"
exit
fi
sleep 2;


echo " "
echo "███████╗██████╗░███████╗███████╗░██████╗░██╗░░░░░░░██╗██╗████████╗░█████╗░██╗░░██╗"
echo "██╔════╝██╔══██╗██╔════╝██╔════╝██╔════╝░██║░░██╗░░██║██║╚══██╔══╝██╔══██╗██║░░██║"
echo "█████╗░░██████╔╝█████╗░░█████╗░░╚█████╗░░╚██╗████╗██╔╝██║░░░██║░░░██║░░╚═╝███████║"
echo "██╔══╝░░██╔══██╗██╔══╝░░██╔══╝░░░╚═══██╗░░████╔═████║░██║░░░██║░░░██║░░██╗██╔══██║"
echo "██║░░░░░██║░░██║███████╗███████╗██████╔╝░░╚██╔╝░╚██╔╝░██║░░░██║░░░╚█████╔╝██║░░██║"
echo "╚═╝░░░░░╚═╝░░╚═╝╚══════╝╚══════╝╚═════╝░░░░╚═╝░░░╚═╝░░╚═╝░░░╚═╝░░░░╚════╝░╚═╝░░╚═╝"
echo " "

sleep 2;
echo This Script Will Install Freeswitch .
echo " "
sleep 1;
echo CREATED BY EMRE SAKA
echo " "
sleep 2;
read -n 1 -r -s -p $'Press Any Key to Start Install Script...\n'
echo " "
echo Starting Install Process.
echo " "
sleep 1;
echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;echo -n "█";sleep .1;
echo " "



echo "#######################################"
echo "#    TOOLKIT INSTALL NOW              #"
echo "#######################################"
sleep 2


echo "AUTO INSTALL İŞLEMİ BAŞLATILIYOR"
sleep 4s


echo "SUDO PAKETİ KURULUYOR"
apt-get install sudo -y
sleep 2s

echo "UPDATE VE UPGRADE İŞLEMLERİ YAPILIYOR"
sudo apt update && sudo apt upgrade -y
sleep 2s

echo "SAAT VE TARIH DUZENLENIYOR"
#sudo timedatectl set-timezone Europe/Istanbul
sleep 2s

echo "HTOP YAZILIMI KURULUYOR"

sudo apt install -y htop
sleep 2s

echo "SCREEN YAZILIMI KURULUYOR"
sudo apt install -y screen
sleep 2s
echo "TCPDUMP YAZILIMI KURULUYOR"
sudo apt install -y tcpdump
sleep 2s
echo "NETTOOLS YAZILIMI KURULUYOR"
sudo apt install -y net-tools
sleep 2s
echo "DNSUTIL YAZILIMI KURULUYOR"
sudo apt install -y dnsutils
sleep 2s
echo "CURL YAZILIMI KURULUYOR"
sudo apt install -y curl
sleep 4s
sudo apt-get install byobu -y  
sleep 4s
sudo apt install sysstat ncdu htop nload pydf iotop -y
sleep 4s
sudo apt-get install gnupg2 -y
sleep 4s
sudo apt-get install ranger -y
sleep 4s
sudo apt-get install ncdu -y
sleep 4s
sudo apt-get install zabbix-agent -y

clear
sleep 2

echo "#######################################"
echo "#   Freeswitch INSTALL NOW            #"
echo "#######################################"
sleep 2


TOKEN=pat_2eUPYHFLMtrzJGbcfQTG53Pe

sleep 2;
apt-get update && apt-get install -y gnupg2 wget lsb-release
clear
sleep 2


wget --http-user=signalwire --http-password=$TOKEN -O /usr/share/keyrings/signalwire-freeswitch-repo.gpg https://freeswitch.signalwire.com/repo/deb/debian-release/signalwire-freeswitch-repo.gpg
sleep 2;
clear
sleep 2
echo "machine freeswitch.signalwire.com login signalwire password $TOKEN" > /etc/apt/auth.conf
sleep 2;
clear
sleep 2
chmod 600 /etc/apt/auth.conf
sleep 2;
clear
sleep 2
echo "deb [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" > /etc/apt/sources.list.d/freeswitch.list
sleep 2;
clear
sleep 2
echo "deb-src [signed-by=/usr/share/keyrings/signalwire-freeswitch-repo.gpg] https://freeswitch.signalwire.com/repo/deb/debian-release/ `lsb_release -sc` main" >> /etc/apt/sources.list.d/freeswitch.list
sleep 2;
clear
sleep 2

apt-get update && apt-get install -y freeswitch-meta-all

clear
sleep 2


echo "#######################################"
echo "#   Change  Container Setting         #"
echo "#######################################"



sleep 2;

sudo sed -i '/^IOSchedulingClass=/d' /usr/lib/systemd/system/freeswitch.service
sudo sed -i '/^IOSchedulingPriority=/d' /usr/lib/systemd/system/freeswitch.service
sudo sed -i '/^CPUSchedulingPolicy=/d' /usr/lib/systemd/system/freeswitch.service
sudo sed -i '/^CPUSchedulingPriority=/d' /usr/lib/systemd/system/freeswitch.service



sudo systemctl daemon-reload
sudo systemctl restart freeswitch



echo "#######################################"
echo "#    SSH AYARLARI YAPILIYOR           #"
echo "#######################################"
sleep 2



# SSHD konfigürasyon dosyası
config_file="/etc/ssh/sshd_config"

# Yedek dosya adı
backup_file="/etc/ssh/sshd_config_backup"

# Önce yedek alalım
cp "$config_file" "$backup_file"

echo Ssh Port Change 22 To 5149
sed -i 's/#Port 22/Port 5149/' "$config_file"
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' "$config_file"

echo operation Done 

# SSH servisini yeniden başlatalım
systemctl restart sshd

echo "Değişiklikler uygulandı. SSH servisi yeniden başlatıldı."

clear
sleep 2
