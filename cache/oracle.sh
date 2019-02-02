#!/bin/bash

#
# Description
# ------
# You must run current directory.

TAG=0.1

# If Windows NT than change initial path.
if [ Z"$(uname -a | grep NT)" != Z ];then
  	PWD="$(pwd | sed s/'\/d\/'/'D:\\'/g)"
else
  	PWD=$(pwd)
fi

docker pull wnameless/oracle-xe-11g
docker tag wnameless/oracle-xe-11g oracle:0.1


# oracle startup
docker run -d \
	--name oracle \
	-p 1521:1521 \
	-p 8090:8080 \
	oracle:${TAG}
