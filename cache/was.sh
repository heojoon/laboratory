#!/bin/bash

# shutdown tomcat
docker rm -f was1 was2

# startup tomcat
docker run -d \
	--name was1 \
	-p 8081:8080 \
	-v ${PWD}/tomcat/conf/server.xml:/usr/local/tomcat/conf/server.xml \
	-v ${PWD}/tomcat/logs/was1:/usr/local/tomcat/logs \
	-v ${PWD}/tomcat/webapps/toywas:/usr/local/tomcat/webapps/toywas \
	tomcat

docker run -d \
	--name was2 \
	-p 8082:8080 \
	-v ${PWD}/tomcat/conf/server.xml:/usr/local/tomcat/conf/server.xml \
	-v ${PWD}/tomcat/logs/was2:/usr/local/tomcat/logs \
	-v ${PWD}/tomcat/webapps/toywas:/usr/local/tomcat/webapps/toywas \
	tomcat
