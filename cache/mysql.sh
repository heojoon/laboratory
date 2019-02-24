#!/bin/bash

# ------
# Description
# ------
# You must run current directory.
# mysql startup

VER=5.7
TAG=dev0.1

# If Windows NT than change initial path.
if [ Z"$(uname -a | grep NT)" != Z ];then
  	PWD="$(pwd | sed s/'\/d\/'/'D:\\'/g)"
else
  	PWD=$(pwd)
fi

# Download docker image to save my local disk`
docker pull mysql:${VER}
docker tag mysql:${VER} mysql:${TAG}

# oracle startup
docker run -d \
	--name mysql \
	-e MYSQL_ROOT_PASSWORD=my_password \
	-p 3306:3306 \
	mysql:${TAG}
