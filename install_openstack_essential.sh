#!/bin/bash
set -o xtrace
apt install software-properties-common
add-apt-repository cloud-archive:ocata
apt update && apt dist-upgrade
apt install python-openstackclient
