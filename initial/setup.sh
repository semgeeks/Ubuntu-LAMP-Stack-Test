#!/bin/bash

#Instructions to use this script 
#
#chmod +x SCRIPTNAME.sh
#
#sudo ./SCRIPTNAME.sh

echo "###################################################################################"
echo "Enabling Apache and php5 modules..."
echo "###################################################################################"

#Enable Apache and php5 modules
sudo php5enmod mcrypt
sudo a2enmod rewrite


#Obtain site name for directory creation and configuration
echo -e "\n"
echo -e "Enter website's domain name, without http:// (this will be the root directory name): "
read sitename

echo "###################################################################################"
echo "Assigning webroot permissions..."
echo "###################################################################################"

#Permissions assignments on /var/www/html/$sitename
WEBROOT=/var/www/html/$sitename
sudo mkdir $WEBROOT
sudo chown www-data:www-data $WEBROOT -R
sudo chmod g+s $WEBROOT
sudo chmod o-wrx $WEBROOT -R

echo "###################################################################################"
echo "Creating new Virtualhost..."
echo "###################################################################################"

#Create virtualhost file
echo "<VirtualHost *:80>
        DocumentRoot ${WEBROOT}/
        ServerName $sitename
        <Directory ${WEBROOT}/>
                Options +Indexes +FollowSymLinks +MultiViews +Includes
                AllowOverride All
                Order allow,deny
                allow from all
        </Directory>
</VirtualHost>" > /etc/apache2/sites-available/$sitename.conf

echo "###################################################################################"
echo "Adding to hosts file..."
echo "###################################################################################"

#Add host to hosts file
echo 127.0.0.1 $sitename >> /etc/hosts

echo "###################################################################################"
echo "Enabling new Virtualhost..."
echo "###################################################################################"

#Enable the new site
sudo a2ensite $sitename

#Php.ini memory limit increases
echo -e "\n"
echo -e "Enter memory limit, upload_max_filesize, and post_max_size for php.ini (e.g. 128M) - Note all three variables will be set to this same value: "
read limit

sed -i -r -e "s/(upload_max_filesize = ).+/\1${limit}/gi" /etc/php5/apache2/php.ini
sed -i -r -e "s/(post_max_size = ).+/\1${limit}/gi" /etc/php5/apache2/php.ini
sed -i -r -e "s/(memory_limit = ).+/\1${limit}/gi" /etc/php5/apache2/php.ini


#Create site db and new user
echo -e "\n"
echo -e "Set website's database name: "
read dbname

echo -e "\n"
echo -e "Set MYSQL username used by the application: "
read dbuser

while true
do
	echo -e "\n"
	echo -e "Set new MYSQL user's password: "
	read -s dbpw
	echo -e "\n"

	echo -e "\n"
	echo -e "Confirm new MYSQL user's password: "
	read -s dbpw2

	[ "$dbpw" = "$dbpw2" ] && break
	    echo "Passwords did not match. Please try again."
done

#Read in mysql root password from temporary file created in installs.sh. Prompt for input if pw.tmp was not created - this script is likely being run standalone.
if [ -e "pw.tmp" ];
then
	rootpw=$(head -n 1 pw.tmp) 
else
	echo -e "\n"
	echo -e "Enter MySQL root user's password: "
	read -s rootpw
fi


sqlcommands="CREATE DATABASE IF NOT EXISTS $dbname;GRANT ALL ON $dbname.* TO $dbuser@localhost IDENTIFIED BY '$dbpw';FLUSH PRIVILEGES;"
mysql -u root -p$rootpw -e "$sqlcommands"


# Obtain git repository information
echo -e "\n"
echo -e "Enter full http git repository URL, or 'q' to skip this step: "
read git_repo

if [[ $git_repo != "q" && $git_repo != "Q" ]];
then

	# Make sure url provided is a .git url
	if [[ $git_repo == *git ]];
	then
		# Clone repository into webroot
		git clone $git_repo $WEBROOT

	else
		echo -e "\n"
		echo "###################################################################################"
		echo "INVALID REPOSITORY URL. TRY AGAIN ONCE SCRIPT EXECUTION HAS COMPLETED."
		echo "###################################################################################"
	fi
fi 