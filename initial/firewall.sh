#!/bin/bash

#Instructions to use this script 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh


echo "###################################################################################"
echo "Configuring Firewall..."
echo "###################################################################################"

#Allow SSH traffic
sudo ufw allow 22/tcp

#Allow HTTP traffic
sudo ufw allow 80/tcp

#Allow HTTPS traffic
sudo ufw allow 443/tcp

#Enable firewall
sudo ufw enable