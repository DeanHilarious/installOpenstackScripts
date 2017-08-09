#!/bin/bash 
set -o xtrace
TOP_DIR="/home/controller"
mysqlUSERNAME="root" 
PASSWORD="123456"
DB_name="glance"
GLANCE_DIR="/etc/glance"
function create_galanceDB {
    mysql -u$mysqlUSERNAME -p$PASSWORD -e"CREATE DATABASE ${DB_name};"
    if [ $? -eq 0 ]; then
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON ${DB_name}.* TO '$DB_name'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON ${DB_name}.* TO '$DB_name'@'%' IDENTIFIED BY '$PASSWORD';"
    fi
}
create_galanceDB
. admin-openrc
function create_serviceCredential {
    openstack user create --domain default --password-prompt glance 
    #source .$TOP_DIR/input_password.sh
    openstack role add --project yaozu_service --user glance admin
    #create the glance service entity
    openstack service create --name glance --description "openstack Image" image
    
}
create_serviceCredential
function create_glanceAPIendpoints {
    openstack endpoint create --region RegionOne image public http://controller:9292 
    openstack endpoint create --region RegionOne image internal http://controller:9292
    openstack endpoint create --region RegionOne image admin http://controller:9292
}
create_glanceAPIendpoints

function installAndCreateConf {
    apt install glance
    if [ $? -eq 0 ]; then
        cd $GLANCE_DIR
        mv glance-api.conf glance-api.conf.bak
        mv glance-registry.conf glance-registry.conf.bak
        touch glance-api.conf glance-registry.conf
        echo -e "[DEAULT]\n[cors]\n[cors.subdomain]\n[database]\nconnection = mysql+pymysql://glance:123456@controller/glance\nbackend = sqlalchemy\n[glance_store]\nstores = file,http\ndefault_store = file\nfilesystem_store_datadir = /var/lib/glance/images/\n[image_format]\ndisk_formats = ami,ari,aki,vhd,vhdx,vmdk,raw,qcow2,vdi,iso,ploop.root-tar\n[keystone_authtoken]\nauth_uri = http://controller:5000\nauth_url = http://controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = yaozu_service\nusername = glance\npassword = 123456\n[matchmaker_redis]\n[oslo_concurrency]\n[oslo_messaging_amqp]\n[oslo_messaging_kafka]\n[oslo_messaging_notifications]\n[oslo_messaging_rabbit]\n[oslo_messaging_zmq]\n[oslo_middleware]\n[oslo_policy]\n[paste_deploy]\nflavor = keystone\n[profiler]\n[store_type_location_strategy]\n[task]\n[taskflow_executor]]" >> glance-api.conf
        echo -e "[DEFAULT]\n[database]\nconnection = mysql+pymysql://glance:123456@controller/glance\nbackend = sqlalchemy\n[keystone_authtoken]\nauth_uri = http://controller:5000\nauth_url = http://controller:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = defult\nuser_domain_name = default\nproject_name = yaozu_service\nusername = glance\npassword = 123456\n[matchmaker_redis]\n[oslo_messaging_amqp]\n[oslo_messaging_kafka]\n[oslo_messaging_notifications]\n[oslo_messaging_rabbit]\n[oslo_messaging_zmq]\n[oslo_policy]\n[paste_deploy]\nflavor = keystone\n[profiler]" >> glance-registry.conf
    fi

}
installAndCreateConf
su -s /bin/sh -c "glance-manage db_sync" glance
service glance-registry restart
service glance-api restart 
function verify_installment {
. ~/admin-openrc 
wget http://download.cirros-cloud.net/0.3.5/cirros-0.3.5-x86_64-disk.img
if [ $? -eq 0 ]; then
    openstack image create "cirros" --file cirros-0.3.5-x86_64-disk.img --disk-format qcow2 --container-format bare --public
fi
openstack image list 
}
verify_installment
