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

## nginx-google-authenticator

nginx with OTP by Google Authenticator.
The key point is also to use [ngx_auth_pam](https://github.com/sto/ngx_http_auth_pam_module).
Install Google Authenticator pam-module:
```
apt-get install libpam-google-authenticator
```

Create pam service config (etc/pam.d/nginx_google), and produce GAs files like this:
```
createuser.sh johndoe
```

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
Also note, that a file set in ssl_client_certificate may contain several client certificates. Current client can be obtained from ngx_http_ssl_module embedded variables. 

gen_csr.sh - creates CSR with SAN for trusted CA and dumps csr content in readable form. 
```
./gen_csr.sh host.tld 

```
SAN, for example, is required by several CA's to create a wildcard cert. Alternative namess should be defined in host.tld.csr.conf among pre-defined defautls. 
When CA requires csr with SAN for wildcard - in most cases you should define main CN as *.host.tld, and first alternative name set to host.tld. 

check_expire.sh - checks a cert's expiration date on a remote host. 
```
$ ./check_expire.sh google.com
Wed May 30 18:50:00 UTC 2018
$
```

## nginx-modules 

An automated script to build additional dynamic modules for official nginx package. 
The script simply build modules for exact installed nginx version and places results into default modules dir. 
The script requires build environment to be set - including GCC, git, -devel packages for libraries, etc. 

Currently builds modules: 

  - Nginx auth_pam module 
  - Nginx brotli module
  - Nginx Lua module
  - Nginx pagespeed module
  - Nginx virtual host traffic status module

## nginx-yum-repo

Minimalistic setup to serve yum-repository with nginx. 
Requirements: 

  - systemd 
  - nginx 
  - createrepo (or, for best performance - C implementation [createrepo_c](https://github.com/rpm-software-management/createrepo_c)

RPM packages are pushed into repository via WebDAV, and, after all packages uploaded, one have to trigger rebuild by http hook. 
```
curl -T package.rpm http://yum.repo.tld/repo/name/package.rpm 
curl http://yum.repo.tld/repoflag/name
```

In general, it's possible to remove hook, and rebuild repodata just on package upload - but, in busy CI environments it will be rebuilding too often. 

## lua-ffi 

Example how to use luajit-ffi with nginx, based on libqrencode. 
First, calling shared library functions requires, that this particular library exists in nginx's process memory space. This could be done with several ways: 

 - using native ffi.load() call; 
 - linking library into nginx binary upon building (either statically or dynamically);
 - using LD_PRELOAD env variable; 

As a most complicated way, in this example ffi.load() is used, loading symbols into separate namespace "libqrencode". 

Then, one have to define all necessary symbols from a libqrencode with ffi.cdef() exactly as they're defined in qrencode.h. 
The rest is quite obvious except the point that *encode functions returns a pointer to array of chars with meaningful lowest bit - so we have to process this array in lua to draw an "image". 

If everything is ok, you should see something like this: 

![sample qr-code](https://github.com/toxatoor/nginx/blob/master/lua-ffi/lua-qrencode.png)

Note, that you're playing in deep water, and there can be leaks and other issues, causing nginx worker to segfault. 
Also note, that init_by_lua_* statements executed upon start master/worker process, and content_by_lua_* - upon accessing to the location, which causes re-reading code when content_by_lua_file is used. So you can run into state when different nginx workers uses different code; therefore in thes example *_by_lua_block is used.  

## nginx-extended-limit_rate 

Extending limit_rate to any time window. 


## nginx-stream-ssh 

Wrapping ssh connection into SSL using nginx-stream module. 
The configuration is quite simple: 
 
  - bind sshd to 127.0.0.1:8022 using ListenAddress in sshd_config; 
  - add stream section into nginx.conf; 
  - add Host configuration into ssh_config (or ~/.ssh/config);

This could be used for extra: 

Security

  - most scanning bots expects ssh handshake on 22/tcp, so they will be confused;
  - adding a client certificate authentication could add a sort of second factor; 

Flexibility

  - as nginx read SSL session date before proxing, it's possible to proxy a single entry point ssh connections to different upstream by SNI, client certificate DN, issue/expiration date, serial etc using variable mapping. Adding lua scripting allows to use extremaly flexible dynamic mappings. 
