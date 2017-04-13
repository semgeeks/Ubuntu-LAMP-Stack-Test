#!/bin/bash

#Instructions to use this script 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh


echo "###################################################################################"
echo "Updating repository information..."
echo "###################################################################################"

#Update the repositories
sudo apt-get update


echo "###################################################################################"
echo "Installing packages..."
echo "###################################################################################"

#Apache, PHP, MySQL, and required packages installation
sudo apt-get -y install apache2 php libapache2-mod-php php-mcrypt php-mysql mysql-client php-curl php7.0-gd zip unzip

#The following commands prompt and set the MySQL root password when you install the mysql-server package.
while true
do
	echo -e "\n"
	echo -e "Create MySQL root password: "
	read -s password
	echo -e "\n"

	echo -e "Confirm MySQL root password: "
	read -s password2

	[ "$password" = "$password2" ] && break
    	echo "Passwords did not match. Please try again."
done

sudo debconf-set-selections <<< "mysql-server mysql-server/root_password password ${password}"
sudo debconf-set-selections <<< "mysql-server mysql-server/root_password_again password ${password}"
sudo apt-get -y install mysql-server

#Output password into file temporarily for use in setup.sh
echo $password > pw.tmp


#Restart all the installed services to verify that everything is installed properly
echo -e "\n"

sudo service apache2 restart && service mysql restart > /dev/null

echo -e "\n"


#Conditional output based on whether or not last command succeeded.
if [ $? -ne 0 ]; then
   echo "Please Check the Install Services, There is some $(tput bold)$(tput setaf 1)Problem$(tput sgr0)"
else
   echo "Installed Services run $(tput bold)$(tput setaf 2)Sucessfully$(tput sgr0)"
fi

echo -e "\n"