#!/bin/bash
set -o xtrace 
function install_keystone
{
    
    apt install keystone
    if [ $? -eq 0 ]; then
         cd /etc/keystone
    else
         echo please retry the installment
    fi 
}
#populate the Identity service database
#su -s /bin/sh -c "keystone-manage db_sync" keystone
function Initialize_repo
{
if [ $? -eq 0 ]; then
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
else
    echo Error!
fi
}

#bootstrap the Identity service
function bootstrap_IdenServer {
    keystone-manage bootstrap --bootstrap-password 123456  --bootstrap-admin-url http://controller:35357/v3/  --bootstrap-internal-url http://controller:5000/v3/  --bootstrap-public-url http://controller:5000/v3/  --bootstrap-region-id RegionOne
}
#bootstrap_IdenServer
#export the admin account
#creat a domain,project users and roles
function create_AuthService {
    openstack project create --domain default --description "Service Project" yaozu_service
    openstack project create --domain default --description "Demo Project" demo 
    openstack user create --domain default --password-prompt demo
    openstack role create user
    openstack role add --project demo --user demo user
}
create_AuthService
#verify the installment
if [ $? -eq 0 ]; then
    openstack token issue
fi

