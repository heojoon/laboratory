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
	-v ${PWD}/nginx/conf/nginx.conf:/etc/nginx/nginx.conf \
	-v ${PWD}/nginx/conf/conf.d:/etc/nginx/conf.d \
	-v ${PWD}/nginx/log:/var/log/nginx \
	-v ${PWD}/nginx/html:/usr/share/nginx/html \
	nginx

# comment
# bmt refferance : https://lahuman1.wordpress.com/2015/05/11/docker%EB%A5%BC-%EC%9D%B4%EC%9A%A9%ED%95%98%EC%97%AC-%EC%9B%B9-%EC%82%AC%EC%9D%B4%ED%8A%B8-%EA%B5%AC%EC%B6%95-%ED%95%98%EA%B8%B0/
