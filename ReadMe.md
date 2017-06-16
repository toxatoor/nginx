# Nginx usecases

## http-session 

nginx/syslog-based HTTP-sniffer. Prerequisites:
 - lua-nginx-module
 - luasocket available under builtin luajit 

## error-code-status 

Simple lua-based extended status, logging errors by http response code - to use with zabbix, etc. Requires lua-nginx-module

## nginx-AD-auth 

nginx http-auth against Microsoft Active Directory. 
In most cases, foreign soft authenticates against AD using LDAP. So nginx got it's own auth_ldap module - but in some complicated AD schemas it doesn't work at all. 
The key point is to use [ngx_auth_pam](https://github.com/sto/ngx_http_auth_pam_module), and set bindings to AD in pam. 
