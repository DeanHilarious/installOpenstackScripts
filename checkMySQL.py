#!/usr/bin/python 
# coding=utf-8
from __future__ import absolute_import,division,print_function
__metaclass__= type
ANSIBLE_METADATA = {
    'metadata_version':'1.1',
    'status':['preview'],
    'supported_by':'community'
}




import re
import string
import traceback

try:
    import MySQLdb
except ImportError:
    mysqldb_found = False
else:
    mysqldb_found = True

from ansible.module_utils.basic import AnsibleModule
from ansible.module_utils.mysql import mysql_connect,mysqldb_found
from ansible.module_utils._text import to_native

VALID_PRIVS = frozenset(('CREATE','DROP','GRANT','GRANT OPTION',
                         'LOCK TABLES', 'REFERENCES', 'EVENT', 'ALTER',
                         'DELETE', 'INDEX', 'INSERT', 'SELECT', 'UPDATE',
                         'CREATE TEMPORARY TABLES', 'TRIGGER', 'CREATE VIEW',
                         'SHOW VIEW', 'ALTER ROUTINE', 'CREATE ROUTINE',
                         'EXECUTE', 'FILE', 'CREATE TABLESPACE', 'CREATE USER',
                         'PROCESS', 'PROXY', 'RELOAD', 'REPLICATION CLIENT',
                         'REPLICATION SLAVE', 'SHOW DATABASES', 'SHUTDOWN',
                         'SUPER', 'ALL', 'ALL PRIVILEGES', 'USAGE', 'REQUIRESSL'))
class InvalidPrivsError(Exception):
    pass
def checkMySQLdb(module,current_cursor,required_db):
    result=dict(
        db_changed=False,
    )
    current_cursor.execute("use %s"%required_db)
    if bool(current_cursor.execute("show tables")==0):
        result['db_changed'] = True
    module.exit_json(changed=result['db_changed'])

def main():
    module = AnsibleModule(
        argument_spec=dict(
            login_user=dict(default=None),
            login_host=dict(default="localhost"),
            login_port=dict(default=3306,type='int'),
            login_password=dict(default=None,no_log=True),
            login_unix_socket=dict(default=None),
            #user=dict(required=True,aliases=['name']),
            required_db=dict(default='mysql'),
            password=dict(default=None,no_log=True),
            host=dict(default="localhost"),
            check_implicit_admin=dict(default=True,type='bool'),
            connect_timeout=dict(default=30,type='int'),
            config_file=dict(default="~/etc/my.cnf.d/openstack.cnf",type='path'),
            sql_log_bin=dict(default=False,type='bool'),
            ssl_cert=dict(default=None,type='path'),
            ssl_key=dict(default=None,type='path'),
            ssl_ca=dict(default=None,type='path'),
        ),
        
        supports_check_mode=True
    )
    login_user = module.params["login_user"]
    login_password = module.params["login_password"]
    login_host = module.params["login_host"]
    login_port = module.params["login_port"]
    login_password = module.params["login_password"]
    login_unix_socket = module.params["login_unix_socket"]
    #user = module.params["user"]
    ssl_cert = module.params["ssl_cert"]
    ssl_key =  module.params["ssl_key"]
    ssl_ca = module.params["ssl_ca"]
    config_file = module.params["config_file"]
    required_db = module.params["required_db"]
    connect_timeout = module.params["connect_timeout"]
    check_implicit_admin = module.params["check_implicit_admin"]
    current_cursor=None
    if not mysqldb_found:
        module.fail_json(msg="The MySQLdb module is  required")
    try:
        if check_implicit_admin:
            try:
                current_cursor=mysql_connect(module,'root','',config_file,ssl_cert,ssl_key,ssl_ca,required_db,connect_timeout)
            except:
                pass
        if not current_cursor:
            current_cursor=mysql_connect(module, login_user, login_password, config_file, ssl_cert, ssl_key, ssl_ca,required_db,connect_timeout)    
    except Exception as e:
        module.fail_json(msg="unable to  connect to database,check login_user and login_password are correct or %s has the credentials.""Exception message:%s"%(config_file,to_native(e)))
    checkMySQLdb(module,current_cursor,required_db)

if __name__ == '__main__':
    main()
