#!/bin/bash
#####################################################################################
#Author:yaozu.rong                                                                  #
#Date:8th.Aug.2017                                                                  #
#E-mail:yaozu.rong@hxt-semitech.com                                                 #
#Version:v1.0                                                                       #
#Function:To deploy the cinder-service                                              #
#####################################################################################
set -o xtrace
TOP_DIR="/home/controller"
mysqlUSERNAME="root"
PASSWORD="123456"
DB_User="nova"
GLANCE_DIR="/etc/nova"
function create_galanceDB {
        mysql -u$mysqlUSERNAME -p$PASSWORD -e"CREATE DATABASE nova_api;"
            mysql -u$mysqlUSERNAME -p$PASSWORD -e"CREATE DATABASE nova;"
                mysql -u$mysqlUSERNAME -p$PASSWORD -e"CREATE DATABASE nova_cell0;"
                    if [ $? -eq 0   ]; then
                                mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO '$DB_User'@'localhost' IDENTIFIED BY '$PASSWORD';"
                                        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO '$DB_User'@'%' IDENTIFIED BY '$PASSWORD';"

}
