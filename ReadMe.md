# Nginx usecases

## http-session 

nginx/syslog-based HTTP-sniffer. Prerequisites:
 - lua-nginx-module
 - luasocket available under builtin luajit 

## error-code-status 

Simple lua-based extended status, logging errors by http response code - to use with zabbix, etc. Requires lua-nginx-module


