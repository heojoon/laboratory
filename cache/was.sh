#!/bin/bash

# shutdown tomcat
docker rm -f was

# startup tomcat
docker run -d \
	--name was \
	-p 8080:8080 \
	-v ${PWD}/tomcat/conf/server.xml:/usr/local/tomcat/conf/server.xml \
	-v ${PWD}/tomcat/logs:/usr/local/tomcat/logs \
	-v ${PWD}/tomcat/webapps/toywas:/usr/local/tomcat/webapps/toywas \
	tomcat
