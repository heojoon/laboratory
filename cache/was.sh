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
LOG_PATH1="../../logs/laboratory/cache/tomcat-1"
LOG_PATH2="../../logs/laboratory/cache/tomcat-2"

# If Windows NT than change initial path.
if [ Z"$(uname -a | grep NT)" != Z ];then
  	PWD="$(pwd | sed s/'\/d\/'/'D:\\'/g)"
else
  	PWD=$(pwd)
fi

# oracle-xe-11g Image download to local
docker pull tomcat
docker tag tomcat tomcat:${TAG} 

# startup tomcat
docker run -d \
	--name was1 \
	-p 8081:8080 \
	-v ${PWD}/tomcat/conf/server.xml:/usr/local/tomcat/conf/server.xml \
	-v ${PWD}/tomcat/webapps/toywas:/usr/local/tomcat/webapps/toywas \
	-v ${PWD}/${LOG_PATH1}:/usr/local/tomcat/logs \
  tomcat:${TAG}

docker run -d \
	--name was2 \
	-p 8082:8080 \
	-v ${PWD}/tomcat/conf/server.xml:/usr/local/tomcat/conf/server.xml \
	-v ${PWD}/tomcat/webapps/toywas:/usr/local/tomcat/webapps/toywas \
	-v ${PWD}/${LOG_PATH2}:/usr/local/tomcat/logs \
  tomcat:${TAG}