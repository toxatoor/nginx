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
echo
}

VER=$(nginx -V 2>&1 )
TMP=$(mktemp -d)
HOMEDIR=$(pwd)


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

MODULES_PATH="${HOMEDIR}/nginx-${VERSION}-modules"
mkdir -p ${MODULES_PATH}

pushd ${TMP}

curl -# http://nginx.org/download/${SRCFILE} > ${SRCFILE}

### Clone repos 

git clone https://github.com/openresty/lua-nginx-module.git      lua-nginx-module
git clone https://github.com/vozlt/nginx-module-vts.git          nginx-module-vts
git clone https://github.com/sto/ngx_http_auth_pam_module.git    ngx_http_auth_pam_module
git clone https://github.com/vkholodkov/nginx-eval-module.git    nginx-eval-module 
git clone https://github.com/aperezdc/ngx-fancyindex.git         ngx-fancyindex
git clone https://github.com/arut/nginx-rtmp-module.git          nginx-rtmp-module
git clone https://github.com/vozlt/nginx-module-url.git          nginx-module-url

git clone https://github.com/openresty/lua-upstream-nginx-module.git       lua-upstream-nginx-module
git clone https://github.com/openresty/headers-more-nginx-module.git       headers-more-nginx-module
git clone https://github.com/openresty/encrypted-session-nginx-module.git  encrypted-session-nginx-module


### Openresty's cross-dependencies
git clone https://github.com/openresty/set-misc-nginx-module.git set-misc-nginx-module
git clone https://github.com/vision5/ngx_devel_kit.git           ngx_devel_kit


### Modules with extra configuration 
git clone https://github.com/pagespeed/ngx_pagespeed.git         ngx_pagespeed
git clone https://github.com/google/ngx_brotli.git               ngx_brotli


### Prepare repos 

( cd lua-nginx-module ; git checkout tags/v0.10.15 ; cd .. ) 
( cd ngx_pagespeed ; git checkout tags/latest-stable ; cd .. ) 
# ( cd set-misc-nginx-module ; git checkout tags/v0.32 ; cd .. ) 

### Prepare dependencies

( cd ngx_brotli ; git submodule update --init ; cd .. )

( cd ngx_pagespeed 

_psol=$( cat PSOL_BINARY_URL )
PSOL_URL=$( eval "echo ${_psol}" )
curl -# "${PSOL_URL}" > psol.tar.gz
tar zxf psol.tar.gz

cd .. ) 

tar zxf ${SRCFILE}
cd ${SRC}
CMD="./configure ${CONFIGURE} \
	--add-dynamic-module=../lua-nginx-module \
	--add-dynamic-module=../nginx-module-vts \
	--add-dynamic-module=../ngx_http_auth_pam_module \
	--add-dynamic-module=../ngx_brotli \
	--add-dynamic-module=../ngx_pagespeed \
	--add-dynamic-module=../ngx_devel_kit \
	--add-dynamic-module=../set-misc-nginx-module \
	--add-dynamic-module=../encrypted-session-nginx-module \
	--add-dynamic-module=../nginx-eval-module \
	--add-dynamic-module=../ngx-fancyindex \
	--add-dynamic-module=../nginx-rtmp-module \
	--add-dynamic-module=../nginx-module-url \
	--add-dynamic-module=../headers-more-nginx-module \
	--add-dynamic-module=../lua-upstream-nginx-module \
	"
eval ${CMD}

( make | spinner ) && cp objs/*.so ${MODULES_PATH}
#( make | spinner ) && ls -l objs/*.so

popd

ls -l ${MODULES_PATH}/

# echo ${TMP}
rm -rf ${TMP}

