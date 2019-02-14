#!/bin/bash

# ------
# Description
# ------
#
# You must run current directory.
# Create a directory for logging outside the syncronization directory of github.
# And Setting the varible path called LOG_PATH.
#

TAG=dev0.1
LOG_PATH="../../logs/laboratory/cache/nginx"


# If Windows NT than change initial path.
if [ Z"$(uname -a | grep NT)" != Z ];then
  	PWD="$(pwd | sed s/'\/d\/'/'D:\\'/g)"
else
  	PWD=$(pwd)
fi

# oracle-xe-11g Image download to local
docker pull nginx
docker tag nginx nginx:${TAG}

# nginx startup
docker run -d  \
	--name nginx \
	-p 80:80 \
	-v ${PWD}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
	-v ${PWD}/nginx/conf/conf.d:/etc/nginx/conf.d \
	-v ${PWD}/nginx/html:/usr/share/nginx/html \
	-v ${PWD}/${LOG_PATH}:/var/log/nginx \
	nginx:${TAG}