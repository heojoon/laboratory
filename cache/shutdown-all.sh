#!/bin/bash

docker ps -qa | xargs docker rm -f 
