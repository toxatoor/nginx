#!/bin/bash

# Build environment
# 
# Debian 9: apt-get install curl make gcc g++ uuid-dev libdpkg-perl luajit libluajit-5.1-dev libpcre3-dev libssl-dev libz-dev libpam0g-dev
# 


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
HOMEDIR=$(pwd)

# PSOL

if [ "$(uname -m)" = x86_64 ]; then
  BIT_SIZE_NAME=x64
else
  BIT_SIZE_NAME=ia32
fi

VERSION=$(echo "${VER}" | grep "^nginx version: " | awk -F 'nginx version: nginx/' '{print $2}')
CONFIGURE=$(echo "${VER}" | grep "^configure arguments: " | awk -F 'configure arguments: ' '{print $2}' | sed -r '
  s/([^\ ]*=dynamic )/ /g;
  s/ --add-dynamic-module=([^\ ]+) / /g;
  s/ --add-module=([^\ ]+) / /g;')

SRC="nginx-${VERSION}"
SRCFILE="nginx-${VERSION}.tar.gz"

curl -# http://nginx.org/download/${SRCFILE} > ${TMP}/${SRCFILE}

git clone https://github.com/openresty/lua-nginx-module.git  		  ${TMP}/lua-nginx-module
git clone https://github.com/sto/ngx_http_auth_pam_module.git 		  ${TMP}/ngx_http_auth_pam_module
git clone https://github.com/vozlt/nginx-module-vts.git 		  ${TMP}/nginx-module-vts
git clone https://github.com/simplresty/ngx_devel_kit.git 		  ${TMP}/ngx_devel_kit
git clone https://github.com/openresty/encrypted-session-nginx-module.git ${TMP}/encrypted-session-nginx-module
git clone https://github.com/openresty/set-misc-nginx-module.git          ${TMP}/set-misc-nginx-module

git clone https://github.com/google/ngx_brotli.git ${TMP}/ngx_brotli
cd ${TMP}/ngx_brotli && git submodule update --init
cd ${HOMEDIR}

git clone -b latest-stable https://github.com/pagespeed/ngx_pagespeed.git ${TMP}/ngx_pagespeed

pushd ${TMP}/ngx_pagespeed
git checkout tags/latest-stable
_psol=$( cat PSOL_BINARY_URL )
PSOL_URL=$( eval "echo ${_psol}" )
curl -# "${PSOL_URL}" > psol.tar.gz
tar zxf psol.tar.gz
popd

pushd ${TMP}

tar zxf ${SRCFILE}
cd ${SRC}

# CMD="./configure ${CONFIGURE} \
# 	--add-dynamic-module=../ngx_devel_kit \
# 	--add-dynamic-module=../encrypted-session-nginx-module \
# 	--add-dynamic-module=../set-misc-nginx-module \
# 	--add-dynamic-module=../lua-nginx-module \
# 	--add-dynamic-module=../ngx_http_auth_pam_module \
# 	--add-dynamic-module=../ngx_brotli \
# 	--add-dynamic-module=../ngx_pagespeed \
# 	--add-dynamic-module=../nginx-module-vts \
# 	"

CMD="./configure ${CONFIGURE} \
	--add-dynamic-module=../lua-nginx-module \
	--add-dynamic-module=../ngx_http_auth_pam_module \
	--add-dynamic-module=../ngx_brotli \
	--add-dynamic-module=../ngx_pagespeed \
	--add-dynamic-module=../nginx-module-vts \
	"
eval ${CMD}

( make | spinner ) && cp objs/*.so /etc/nginx/modules
ls -l /etc/nginx/modules/*.so

popd

rm -rf ${TMP}

