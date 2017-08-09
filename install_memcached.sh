#!/bin/bash
apt install memcached python-memcache
str1="-l 127.0.0.1"
str2="-l 192.168.98.131"
cd /etc/ 

sed -i 's/${str1}/${str2}/g' memcached.conf
service memcached restart
