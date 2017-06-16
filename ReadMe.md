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

## ssl-certs

A bunch of scripts to generate self-signed SSL certs, client .p12 certs, and csr's with SAN. 

gen_server.sh - creates self-signed cert/key and DH-params file. 
```
./gen_server.sh host.tld 

```

gen_client.sh - creates client .p12 cert to use with certificate authentication. Usage example shown in nginx-client-cert.conf
```
./gen_client.sh host.tld 

```
Note, that it's possible to use self-signed client certs with a host cert, signed by any trusted CA. 
Also note, that a file set in ssl_client_certificate may contain more several client certificates. Current client can be obtained from ngx_http_ssl_module embedded variables. 

gen_csr.sh - creates CSR with SAN for trusted CA and dumps csr content in readable form. 
```
./gen_csr.sh host.tld 

```
SAN, for example, is required by several CA's to create a wildcard cert. Alternative namess should be defined in host.tld.csr.conf among pre-defined defautls. 
When CA requires csr with SAN for wildcard - in most cases you should define main CN as *.host.tld, and first alternative name set to host.tld. 
