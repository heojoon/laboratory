#!/bin/bash

#
# Description
# ------
# You must run current directory.


# nginx remove
docker rm -f nginx

# nginx startup
docker run -d  \
	--name nginx \
	-p 80:80 \
	-e WAS_IP="172.17.0.4" \
	-v ${PWD}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
	-v ${PWD}/nginx/conf/conf.d:/etc/nginx/conf.d \
	-v ${PWD}/nginx/log:/var/log/nginx \
	-v ${PWD}/nginx/html:/usr/share/nginx/html \
	nginx
