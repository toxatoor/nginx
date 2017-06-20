#!/bin/bash

function spinner() {
i=1
sp="/-\|"
echo -n ' '
while read line
do
  printf "\b${sp:i++%${#sp}:1}"
  done
}

VER=$(nginx -V 2>&1 )
TMP=$(mktemp -d)

VERSION=$(echo "${VER}" | grep "^nginx version: " | awk -F 'nginx version: nginx/' '{print $2}')
CONFIGURE=$(echo "${VER}" | grep "^configure arguments: " | awk -F 'configure arguments: ' '{print $2}' | sed -r '
  s/([^\ ]*=dynamic )/ /g;
  s/ --add-dynamic-module=([^\ ]+) / /g;
  s/ --add-module=([^\ ]+) / /g;')

SRC="nginx-${VERSION}"
SRCFILE="nginx-${VERSION}.tar.gz"

curl -# http://nginx.org/download/${SRCFILE} > ${TMP}/${SRCFILE}

git clone https://github.com/openresty/lua-nginx-module.git  ${TMP}/lua-nginx-module
git clone https://github.com/sto/ngx_http_auth_pam_module.git ${TMP}/ngx_http_auth_pam_module

pushd ${TMP}

tar zxf ${SRCFILE}
cd ${SRC}
CMD="./configure ${CONFIGURE} --add-dynamic-module=../lua-nginx-module --add-dynamic-module=../ngx_http_auth_pam_module "
eval ${CMD}
( make | spinner ) && cp objs/*.so /etc/nginx/modules
ls -l /etc/nginx/modules/*.so

popd

rm -rf ${TMP}

