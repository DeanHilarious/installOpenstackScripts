#!/bin/bash 
set -o xtrace
function config_apache2 {
    echo -e "ServerName controller">>/etc/apache2/apache2.conf
    if [ $? -eq 0 ]; then
        service apache2 restart
            if [ $? -eq 0 ]; then
            sudo rm -f /var/lib/keystone/keystone.db
            else
                exit 1
            fi
    fi
}
config_apache2
#configure the administrative account
. ~/admin-openrc
function config_adminAccount {
    export OS_USERNAME=admin 
    export OS_PASSWORD=123456
    export OS_PROJECT_NAME=admin 
    export OS_USER_DOMAIN_NAME=Default
    export OS_AUTH_URL=http://controller:35357/v3
    export OS_IDENTITY_API_VERSION=3
}
#config_adminAccount 
