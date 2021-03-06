# ilovelamp
*AMP stack install and basic config

Do you really love LAMP? Or are you just looking at repositories and saying you love them?

## Notes
It is not recommended to keep this repository in a publicly accessible directory on the target server. For best results, run as root user or with root-level access on a VPS (shared hosting functionality to be added later). Currently assumes a Debian-based Linux distribution but may be expanded in the future to support Red Hat-based distributions.


# Setup
##ilovelamp
Once you've connected to your sever with ssh run the following commands:


    sudo apt-get update
    sudo apt-get install git
    sudo git clone https://github.com/semgeeks/ilovelamp.git
    cd ilovelamp/initial/
    sudo chmod +x ill.sh
    sudo ./ill.sh


Once you've executed ill.sh you'll be prompted to input information. If you're unsure of what to put refer to this the inputs below which are listed in the same order as you'll be asked.


    <MYSQL unique password>
    <MYSQL unique password confirm>
    <site name>
    y
    64m
    <site name>_db
    <site name>_db_user
    <database user unique password>
    <database user unique password confirm>
    <path to git repo>
    <your git username>
    <your git password>
    yes <enter>
    yes <enter>


##Let's Encrypt
Once you've set up your server you might as well set up an ssl certificate while you're there. Below are the steps to generate an ssl certificate and force ssl on your server with let's encrypt.

First is going into your opt folder where 3rd party software should be installed. Then clone the Let's Encrypt repository from git. Once you've pulled that down you're going to be running an apache install.


    cd /opt
    git clone https://github.com/letsencrypt/letsencrypt
    cd letsencrypt
    ./letsencrypt-auto --apache --agree-tos


The rest is done in their gui. We don't have steps for this yet, this will probably be automated later. You should probably select all relevant domains when generating the ssl (example.com and www.example). You should force https. Emails should be directed to dev@semgeeks.com. 

After that your site should be set up with https but the ssl certificate will run out in a couple months. So the next step is automating the renewal of your ssl certificates by running by setting up a cron job in your crontab. To access your crontab run these commands: 


    cd /etc
    sudo vim crontab


Next add this line somewhere in your crontab: (be sure to replace the word <user> with the user you're running these commands as for example: root)

    30 2 * * 1 <user> sudo /opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log



Save your file and run this command to test if renewing is working by running this command:

    sudo /opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log


If the command went through you're done. If you got permissions errors you'll have to add your user to the group that can edit files in the log folder. Run these commands, which will update the users group and log you out so that the changes take place: (be sure to replace <user> with the same account as your cron job)


    sudo adduser <user> syslog
    logout


Log back in and run a test renewal like before chances are this time you shouldn't get any errors:


    sudo /opt/letsencrypt/letsencrypt-auto renew >> /var/log/le-renew.log



# Initial
### ill.sh
This is the primary wrapper script to execute all of the specified scripts in the "Initial" folder. To execute, run `chmod +x ill.sh` or assign appropriate execution permissions to the user. If scripts are added/removed, they must be appropriately adjusted in this file unless being run solely on their own.

### installs.sh
After running the preliminary installs, the script prompts to create the MySQL root user's password. Pay close attention to what is input as typed characters will not be shown on screen. Script then writes password to temporary file for use in other scripts. DELETE pw.tmp IF THIS SCRIPT IS BEING RUN BY ITSELF WITHOUT CLEANUP!

Core Packages installed (latest stable versions unless otherwise mentioned):
- Apache2
- php5 and various extensions
- MySQL server and client
- cURL
- Composer
- NodeJS 5.x (npm included in installation)
- Bower
- Gulp


### setup.sh
Assumes package dependencies have been installed by installs.sh. When prompted for the following information, see the associated requirements:

- Site Directory Name:
  - Use the website's current or intended domain name. This information will get fed into the 'ServerName' field in the next step when creating the new VirtualHost. Adjustments will be made to the webroot if the project to be cloned later in the script is a Roots Bedrock-based installed.
- Php.ini limits
  - Note the variables shown will all be changed to the same value and must have a trailing M or G depending on the value given. If "32M" was supplied, upload_max_filesize, post_max_size, memory_limit will all be changed to 32M simultaneously. For websites requiring video uploads or large files, a larger limit may be necessary. Recommended to set at at least 8M as the default is 2M and typically needs to be raised.
- Database Information
  - The credentials created here are to be used for the operation of the website. The user created for this database will only be assigned privileges to this database.
- Git Information
  - Entering a git repository URL at the prompt allows the script to clone the repository to the web root. If the git project specified is a Roots Bedrock-based project, it will run its associated dependency installs.

### security.sh
Basic Security Software Installed:
- fail2ban
  - Default configuration copied to the local jail file. Use a text editor and open "/etc/fail2ban/jail.local" to make any changes.
- iptables-persistent
  - When iptables-persistent is installed, it prompts to save the current configuration for ipv4 and ipv6 to a file for reuse in the event the server is restarted. Before installation, the firewall is set to only allow traffic to the server on tcp ports 80 (HTTP), 443 (HTTPS), 22 (SSH/SFTP), and 3306 (MySQL); all other traffic is dropped.


### cleanup.sh
Removes any .tmp files that were used and restarts the Apache and MySQL services.

# Utilities
### update_wp_urls.sh
Updates URLs in a specified database from an old URL to a new URL. Useful after moving a WordPress site from a development/staging/live environment to another environment. This updates the wp_options, wp_posts (guid and posts), and wp_postmeta tables.

# Changelog
Version 1.0
- Initial version.