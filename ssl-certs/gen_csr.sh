#!/bin/bash

openssl req -new -newkey rsa:2048 -config $1.csr.conf -nodes -keyout $1.key -out $1.csr

openssl req -in $1.csr -noout -text
