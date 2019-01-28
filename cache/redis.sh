#!/bin/bash

# startup redis

docker run -d \
	--name redis \
	-p 6379:6379 \
	-v data:/data \
	redis
