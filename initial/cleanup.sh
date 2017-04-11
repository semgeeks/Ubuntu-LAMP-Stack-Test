#!/bin/bash

#Instructions to use this script 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh

echo "###################################################################################"
echo "Cleaning up temporary files..."
echo "###################################################################################"

#Remove temporary files
sudo rm -rf *.tmp

#Restart servers to read in new configurations
sudo service apache2 restart && service mysql restart > /dev/null