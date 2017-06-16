#!/bin/bash

openssl req -new -newkey rsa:2048 -text -out cert.req -days 730
openssl rsa -in privkey.pem -out cert.pem
openssl req -x509 -in cert.req -text -key cert.pem -out cert.cert -days 730
openssl dhparam -out dhparams.pem 2048

cp cert.pem $1.key
cp cert.cert $1.cert

rm cert.* privkey*

