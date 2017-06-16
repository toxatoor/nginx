#!/bin/bash

openssl req -new -newkey rsa:2048 -text -out cert.req -days 730
openssl rsa -in privkey.pem -out cert.pem
openssl req -x509 -in cert.req -text -key cert.pem -out cert.cert -days 730
openssl pkcs12 -export -in cert.cert -inkey cert.pem -out cert.p12 

cp cert.cert $1.client.cert 
cp cert.p12 $1.client.p12

rm cert.* privkey*

