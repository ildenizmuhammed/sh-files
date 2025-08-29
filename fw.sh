#!/bin/bash



sleep 2;
echo " "
echo "███████████████████████████████████████████████"
echo "█▄─▄█▄─▄▄─█─▄─▄─██▀▄─██▄─▄─▀█▄─▄███▄─▄▄─█─▄▄▄▄█"
echo "██─███─▄▄▄███─████─▀─███─▄─▀██─██▀██─▄█▀█▄▄▄▄─█"
echo "▀▄▄▄▀▄▄▄▀▀▀▀▄▄▄▀▀▄▄▀▄▄▀▄▄▄▄▀▀▄▄▄▄▄▀▄▄▄▄▄▀▄▄▄▄▄▀"
echo " "
sleep 2;
echo This Script Will Install Iptables firewall .
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


echo "---------------------------------------"
echo -e "\e[91miptables kuruluyor\e[0m"
echo "---------------------------------------"
sleep 4s

sudo apt-get install iptables -y 

clear


echo "---------------------------------------"
echo -e "\e[91m Create file\e[0m"
echo "---------------------------------------"
sleep 4s

# Create file /etc/network/if-up.d/iptables
echo "Creating file /etc/network/if-up.d/iptables..."
sleep 3
cat << 'EOF' > /etc/network/if-up.d/iptables
#!/bin/sh
iptables-restore < /etc/iptables.conf
EOF

# Give info after creating the file
echo "File created successfully"

# Make the file executable
echo "Setting permissions for the file..."
chmod +x /etc/network/if-up.d/iptables
sleep 3
echo "Permissions granted"

echo "---------------------------------------"
echo -e "\e[91m Create iptables file\e[0m"
echo "---------------------------------------"
sleep 4s


# Create /etc/iptables.conf and import lines
echo "Creating /etc/iptables.conf..."
sleep 3
cat << 'EOF' > /etc/iptables.conf
*filter
:INPUT DROP [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]

-A INPUT -d 127.0.0.1 -j ACCEPT
-A INPUT -s 127.0.0.1 -j ACCEPT
-A INPUT -i lo -j ACCEPT
-A INPUT -i eth1 -j ACCEPT

#########################################################################################
################################## STATIC  ACCESS  ######################################
#########################################################################################
#ENABLE RETURN TRAFFIC
-A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT



#########################################################################################
################################## SERVER  ACCESS  ######################################
#########################################################################################





#########################################################################################
################################## VOICE NETWORK  ACCESS  ###############################
#########################################################################################
#-A INPUT -s 0.0.0.0 -j ACCEPT -m comment --comment "comment here"
#-A INPUT -s 0.0.0.0 -j ACCEPT -m comment --comment "comment here"


-A INPUT -p tcp --dport 5149  -j ACCEPT

#########################################################################################
################################## NOC  ACCESS  #########################################
#########################################################################################
-A INPUT -s 154.12.254.224    -j ACCEPT -m comment --comment "emre vpn ip address"
-A INPUT -s 213.14.182.239    -j ACCEPT -m comment --comment "Emre Home ip"
-A INPUT -s 161.97.78.221     -j ACCEPT -m comment --comment "Teknik VPN"
-A INPUT -s 159.146.105.34    -j ACCEPT -m comment --comment "Telpass Office"




COMMIT
EOF


echo "---------------------------------------"
echo -e "\e[91m Start Restore Process\e[0m"
echo "---------------------------------------"
sleep 4s


# Give info after creating /etc/iptables.conf
echo "iptables configuration file created successfully"

# Give info about adding firewall rules
echo "Adding firewall rules..."
sleep 3

# Apply firewall rules
echo "Applying firewall rules..."
iptables-restore < /etc/iptables.conf
sleep 3

# Give info after applying firewall rules
echo "Firewall rules applied successfully"

# Show current iptables rules
echo "Current iptables rules:"
iptables -L -n

# Give info after showing iptables rules
echo "Firewall configuration completed"
