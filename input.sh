#!/usr/bin/expect 
set -o xtrace
sudo useradd rong
expect "[sudo] password for controller"
send "      \r"
