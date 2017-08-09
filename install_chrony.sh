#!/bin/bash 
#This script is design to install and configure the chrony service automitically
#Author:YaozuRong
#date:Aug.02nd.2017
#mail:yaozu.rong@hxt-semitech.com
#location:HXT-Semitech,Gui'an building

set -o xtrace
TOP_DIR='/etc/chrony'
apt-get install chrony
cd /etc/chrony/
echo "server controller iburst">>chrony.conf
echo  "allow 192.168.98.0/24">>chrony.conf
service chrony restart
#function install_chrony
#{
    #if[$? -eq 0]
    #then
    #cd $TOP_DIR 
    #else 
    #echo "can't install chrony,Please check your network"
    #fi
#}
