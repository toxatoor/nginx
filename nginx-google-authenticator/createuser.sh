#!/bin/bash
USER=$1
google-authenticator -t -l "${USER} at my.web.site" -D -f -u -w 10  -s /etc/nginx/gauth/${USER}
chown nginx:nginx /etc/nginx/gauth/${USER}
