#!/bin/bash
set -o xtrace
apt install mariadb-server python-pymysql
cd /etc/mysql/mariadb.conf.d/ 
touch 99-openstack.cnf
echo -e "[mysqld]\nbind-address = 192.168.98.128\ndefault-storage-engine = innodb\ninnodb_file_per_table = on\nmax_connections = 4096\ncollation-server = utf8_general_ci\ncharacter-set-server = utf8"> 99-openstack.cnf
service mysql restart
mysql_secure_installation
