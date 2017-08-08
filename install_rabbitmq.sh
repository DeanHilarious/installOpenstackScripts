#!/bin/bash
#To install the rabbitmq_server
RABBIT_PASS=123456
apt install rabbitmq-server
rabbitmqctl add_user openstack $RABBIT_PASS
rabbitmqctl set_permissions openstack ".*" ".*" ".*"
