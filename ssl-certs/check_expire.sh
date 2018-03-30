#!/bin/bash

domain=$1

/bin/date --utc  --date "$(echo "Q" | openssl s_client -connect ${domain}:443 -servername ${domain}  2>/dev/null  | openssl x509 -noout -enddate  | awk -F'=' '{print $2}' )"
