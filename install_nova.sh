#####################################################################################
#!/bin/bash                                                                         #
#Author:yaozu.rong                                                                  #
#Date:3rd.Aug.2017                                                                  #
#E-mail:yaozu.rong@hxt-semitech.com                                                 #
#Version:v1.0                                                                       #
#Function:To deploy the glance-service                                              #
#####################################################################################
set -o xtrace
function create_NovaDatabase {
    database_passwd = 123456
    database_name = 'glance'
    mysql -u root -p $database_passwd   
    if [ $? -eq 0 ]; then
        CREATE_DATABASE $database_name;
    fi
}
