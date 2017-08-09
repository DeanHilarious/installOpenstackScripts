#!/bin/bash
#####################################################################################
#Author:yaozu.rong                                                                  #
#Date:8th.Aug.2017                                                                  #
#E-mail:yaozu.rong@hxt-semitech.com                                                 #
#Version:v1.0                                                                       #
#Function:To deploy the neutron-service                                              #
#####################################################################################
set -o xtrace
TOP_DIR="/home/controller"
mysqlUSERNAME="root"
PASSWORD="123456"
DB_User="neutron"
GLANCE_DIR="/etc/neutron"
function create_neutronDB {
    mysql -u$mysqlUSERNAME -p$PASSWORD -e"CREATE DATABASE neutron;"
    if [ $? -eq 0   ]; then
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON neutron.* TO '$DB_User'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON neutron.* TO '$DB_User'@'%' IDENTIFIED BY '$PASSWORD';"
    fi
}
create_neutronDB
. ~/admin-openrc 
function neutronServiceCredential {
    openstack user create --domain default --password-prompt neutron 
    openstack role add --project yaozu_service --user neutron admin 
    openstack service create --name neutron --description "Openstack Networking" network
}
neutronServiceCredential
function neutronAPIendpoints {
    openstack endpoint create --region RegionOne network public http://controller:9696
    openstack endpoint create --region RegionOne network internal http://controller:9696
    openstack endpoint create --region RegionOne network admin http://controller:9696
}
