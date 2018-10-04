#!/bin/sh
set -e

# Script Variables
NO_COLOR='\033[0m'
COLOR_DANGER='\033[0;31m'
COLOR_INFO='\033[1;34m'
INFO_LABEL="*** [INFO] "
WARNING_LABEL="*** [WARNING] "
ERROR_LABEL="*** [ERROR] "
CONFIG_EXTENSION=".conf"
DATE=`date '+%Y-%m-%d %H:%M:%S'`
LOG_FILE="$(dirname pwd)/logs/vhost/vhost${DATE}.log"

# Get the name of vhost
echo "================================================================="
read -p ">>>>>    Please input the name of virtual host name:  " SELECTED
read -p ">>>>>    Please input the email of Server Admin:  " SERVER_ADMIN
read -p ">>>>>    Please input the Server Alias:  " SERVER_ALIAS
echo "${COLOR_INFO}$INFO_LABEL[${DATE}]   ${NO_COLOR}You selected: $SELECTED"  | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" >> $LOG_FILE

# VALIDATIONS:
# Check if file exists in sites-available, if yes throw error
if [ -f "/etc/apache2/sites-available/${SELECTED}$CONFIG_EXTENSION" ]; then
    echo "${COLOR_DANGER}$ERROR_LABEL $DATE    ${NO_COLOR}File $SELECTED exists already"  >> $LOG_FILE
    exit 1
fi

# Check if inputted file all exists
if [ -z "$SELECTED" ]; then
    echo "${COLOR_DANGER}$ERROR_LABEL $DATE    ${NO_COLOR}No Virtual Host Name input!"  | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" >> $LOG_FILE
fi

if [ -z "$SERVER_ADMIN" ]; then
    echo "${COLOR_DANGER}$ERROR_LABEL $DATE    ${NO_COLOR}No Server Admin input!"  | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" >> $LOG_FILE
fi

if [ -z "$SERVER_ALIAS" ]; then
    echo "${COLOR_DANGER}$ERROR_LABEL $DATE    ${NO_COLOR}No Server Alias input!"  | sed -r "s/\x1B\[([0-9]{1,2}(;[0-9]{1,2})?)?[mGK]//g" >> $LOG_FILE
fi

# Create Vhost file
cat >  ${SELECTED}$CONFIG_EXTENSION << EOF
<VirtualHost *:80>
    ServerAdmin ${SERVER_ADMIN}
    ServerName ${SELECTED}
    ServerAlias ${SERVER_ALIAS}
    DocumentRoot /var/www/${SELECTED}/public
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Move to Apache Folder
sudo mv ${SELECTED}$CONFIG_EXTENSION /etc/apache2/sites-available/${SELECTED}$CONFIG_EXTENSION

# Enable New Vhost Files
sudo a2ensite ${SELECTED}$CONFIG_EXTENSION

# Enable Apache
sudo service apache2 restart

# Reload
sudo systemctl reload apache2