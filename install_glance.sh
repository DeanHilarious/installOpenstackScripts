#!/bin/bash 
set +o xtrace
TOP_DIR="/home/controller"
USERNAME="root" 
PASSWORD="123456"
DB_name="glance"
GLANCE_DIR="/etc/glance"
function create_galanceDB {
    mysql -u$USERNAME -p$PASSWORD -e"CREATE DATABASE ${DB_name};"
    if [ $? -eq 0 ]; then
        mysql -u$USERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON ${DB_name}.* TO '$USERNAME'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$USERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON ${DB_name}.* TO '$USERNAME'@'%' IDENTIFIED BY '$PASSWORD';"
    fi
}
create_galanceDB
. admin-openrc
function create_serviceCredential {
    openstack user create --domain default --password-prompt glance 
    #source .$TOP_DIR/input_password.sh
    openstack role add --project yaozu_service --user glance admin
    
}
create_serviceCredential
function create_glanceServiceEntity {
    openstack service create --name glance --description "openstack Image" image
    openstack endpoint create --region RegionOne image public http://controller:9292 
    openstack endpoint create --region RegionOne image internal http://controller:9292
    openstack endpoint create --region RegionOne image admin http://controller:9292
}
create_glanceServiceEntity

function installAndCreateConf {
    apt install glance
    if [ $? -eq 0 ]; then
        mv $GLANCE_DIR/glance-api.conf $GLANCE_DIR/glance-api.conf.bak
        mv $GLANCE_DIR/glance-registry.conf $GLANCE_DIR/glance-registry.conf.bak
        touch glance-api.conf glance-registry.conf
        #echo -e "" >> glance-api.conf
        #echo -e "" >> glance-registry.conf
    fi

}
installAndCreateConf
#su -s /bin/sh -c "glance-manage db_sync" glance
#service glance-registry restart
#service glance-api restart 
