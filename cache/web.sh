#!/bin/bash

#
# Description
# ------
# You must run current directory.


# If Windows NT than change initial path.
if [ Z"$(uname -a | grep NT)" != Z ];then
  	PWD="$(pwd | sed s/'\/d\/'/'D:\\'/g)"
else
  	PWD=$(pwd)
fi

# nginx startup
docker run -d  \
	--name nginx \
	-p 80:80 \
	-v ${PWD}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
	-v ${PWD}/nginx/conf/conf.d:/etc/nginx/conf.d \
	-v ${PWD}/nginx/html:/usr/share/nginx/html \
	nginx

# Skip mount volumn for log
	#-v ${PWD}/nginx/log:/var/log/nginx \