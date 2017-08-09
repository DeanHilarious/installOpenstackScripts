#####################################################################################
#!/bin/bash                                                                         #
#Author:yaozu.rong                                                                  #
#Date:8th.Aug.2017                                                                  #
#E-mail:yaozu.rong@hxt-semitech.com                                                 #
#Version:v1.0                                                                       #
#Function:To deploy the glance-service                                              #
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
    if [ $? -eq 0  ]; then
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO '$DB_User'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_api.* TO '$DB_User'@'%' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO '$DB_User'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova.* TO '$DB_User'@'%' IDENTIFIED BY '$PASSWORD';"      
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO '$DB_User'@'localhost' IDENTIFIED BY '$PASSWORD';"
        mysql -u$mysqlUSERNAME -p$PASSWORD -e "GRANT ALL PRIVILEGES ON nova_cell0.* TO '$DB_User'@'%' IDENTIFIED BY '$PASSWORD';"
    fi
}
create_galanceDB
. ~/admin-openrc 
function computeServiceCredential {
    openstack user create --domain default --password-prompt nova 
    openstack role add --project yaozu_service --user nova admin 
    openstack service create --name nova --description "openstack compute" compute
}
computeServiceCredential
function computeAPIendpoints {
    openstack endpoint create --region RegionOne compute public http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute internal http://controller:8774/v2.1
    openstack endpoint create --region RegionOne compute admin http://controller:8774/v2.1 
}
computeAPIendpoints
function createPlacementService {   
    openstack user create --domain default --password-prompt placement
    openstack role add --project yaozu_service --user placement admin 
}
createPlacementService
function PlacementAPIentry {
    openstack service create --name placement --description "placement API" placement
}
PlacementAPIentry
function PlacementAPIendpoints {
    openstack endpoint create --region RegionOne placement public http://controller:8778
    openstack endpoint create --region RegionOne placement internal http://controller:8778 
    openstack endpoint create --region RegionOne placement admin http://controller:8778
}
PlacementAPIendpoints 

function install_NovaPackages {
    apt install nova-api nova-conductor nova-consoleauth nova-novncproxy nova-scheduler  nova-placement-api 
} 
install_NovaPackages 
if [ $? -eq 0 ]; then
        cd /etc/nova 
        mv nova.conf nova.conf.bak
        touch nova.conf
        echo -e "[DEFAULT]\ntransport_url = rabbit://openstack:123456@controller\nmy_ip=192.168.98.131\nuse_neutron = True\nfirewall_driver=nova.virt.firewall.NoopFirewallDriver\ndhcpbridge_flagfile=/etc/nova/nova.conf\ndhcpbridge=/usr/bin/nova-dhcpbridge\nforce_dhcp_release=true\nstate_path=/var/lib/nova\nenabled_apis=osapi_compute,metadata\n[api]\nauth_strategy = keystone\n[api_database]\nconnection = mysql+pymysql://nova:123456@controller/nova_api\n[barbican]\n[cache]\n[cells]\nenable=False\n[cinder]\n[cloudpipe]\n[conductor]\n[console]\n[consoleauth]\n[cors]\n[cors.subdomain]\n[crypto]\n[database]\nconnection = mysql+pymysql://nova:123456@controller/nova\n[ephemeral_storage_encryption]\n[filter_scheduler]\n[glance]\napi_server = http://controller:9292\n[guestfs]\n[healthcheck]\n[hyperv]\n[image_file_url]\n[ironic]\n[key_manager]\n[keystone_authtoken]\nauth_uri = http://controller:5000\nauth_url = http://controler:35357\nmemcached_servers = controller:11211\nauth_type = password\nproject_domain_name = default\nuser_domain_name = default\nproject_name = yaozu_service\nusername=nova\npassword=123456\n[libvirt]\n[matchmaker_redis]\n[metrics]\n[mks]\n[neutron]\nurl = http://controller:9696\nauth_url = http://controller:35357\n auth_type = password\nproject_domain_name = default\nuser_domainz_name = default\nregion_name = RegionOne\nproject_name = yaozu_service\nusername = neutron\npassword = 123456\nservice_metadata_proxy = true\nmetadata_proxy_shared_secret = 123456\n[notifications]\n[osapi_v21]\n[oslo_concurrency]\nlock_path = /var/lib/nova/tmp\n[oslo_messaging_amqp]\n[oslo_messaging_kafka]\n[oslo_messaging_notifications]\n[oslo_messaging_rabbit]\n[oslo_messaging_zmq]\n[oslo_middleware]\n[oslo_policy]\n[pci]\n[placement]\nos_region_name = RegionOne\nproject_domain_name = Default\nproject_name = yaozu_service\nauth_type = password\nuser_domain_name =Default\nauth_url = http://controller:35357/v3\nusername = placement\npassword = 123456\n[quota]\n[rdp]\n[remote_debug]\n[scheduler]\n[serial_console]\n[service_user]\n[spice]\n[ssl]\n[trusted_computing]\n[upgrade_levels]\n[vendordata_dynamic_auth]\n[vmware]\n[vnc]\nenabled=true\nvncserver_listen = $my_ip\nvncserver_proxyclient_address = $my_ip\n[workarounds]\n[wsgi]\napi_paste_config=/etc/nova/api-paste.ini\n[xenserver]\n" >> nova.conf
    fi
    su -s /bin/sh -c "nova-manage api_db sync" nova
    su -s /bin/sh -c "nova-manage cell_v2 map_cell0" nova
    su -s /bin/sh -c "nova-manage cell_v2 create_cell --name=cell --verbose" nova 
    su -s /bin/sh -c "nova-manage db sync" nova 


install_NovaPackages 
if [ $? -eq 0 ];  then 
    nova-manage cell_v2 list_cells
    service nova-api restart
    service nova-consoleauth restart 
    service nova-scheduler restart
    service nova-conductor restart 
    service nova-novncproxy restart 
fi 

