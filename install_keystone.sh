#!/bin/bash
set -o xtrace 
function install_keystone
{
    
    apt install keystone
    if [ $? -eq 0 ]; then
         cd /etc/keystone
         mv keystone.conf keystone.conf.bak
         touch keystone.conf
         echo -e "[DEFAULT]\n[assignment]\n[auth]\n[cache]\n[catalog]\n[cors]\n[cors.subdomain]\n[credential]\n[database]\nconnection=mysql+pymysql://keystone:123456@controller/keystone\n[domain_config]\n[endpoint_filter]\n[endpoint_policy]\n[eventlet_server]\n
[extra_headers]\n[federation]\n[fernet_tokens]\n[healthcheck]\n[identity]\n[identity_mapping]\n[kvs]\n[ldap]\n[matchmaker_redis]\n[memcache]\n[oauth1]\n[oslo_messaging_amqp]\n[oslo_messaging_kafka]\n[oslo_messaging_notifications]\n[oslo_messaging_rabbit]\n[oslo_messaging_zmq]\n[oslo_middleware]\n[oslo_policy]\n[paste_deploy]\n[policy]\n[profiler]\n[resource]\n[revoke]\n[role]\n[saml]\n[security_compliance]\n[shadow_users]\n[signing]\n[token]\nprovider=fernet\n[tokenless_auth]\n[trust]" >>keystone.conf
    else
         echo please retry the installment
    fi 
}
#install_keystone
#su -s /bin/sh -c "keystone-manage db_sync" keystone

#populate the Identity service database
function Initialize_repo
{
if [ $? -eq 0 ]; then
    keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
    keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
fi
}
Initialize_repo
. ~/admin-openrc
#bootstrap the Identity service
function bootstrap_IdenServer {
    keystone-manage bootstrap --bootstrap-password 123456  --bootstrap-admin-url http://controller:35357/v3/  --bootstrap-internal-url http://controller:5000/v3/  --bootstrap-public-url http://controller:5000/v3/  --bootstrap-region-id RegionOne
}
bootstrap_IdenServer
. ~/config_apache2.sh 
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

