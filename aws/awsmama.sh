#!/bin/bash

# ---------------------------------
#  ec2 controll script v0.1
# ---------------------------------

# -- AWS configure --
# AWS Access Key ID [****************ELH5]:
# AWS Secret Access Key [****************HliD]:
# Default region name [ap-northeast-2]:
# Default output format [json]:


# instance id
#aws ec2 describe-instances --query 'Reservations[*].Instances[*].InstanceId' --output json

aws ec2 describe-instances --query 'Reservations[*].Instances[*]' --output json
# > tmp.tmp
#InstanceId=`sh tmp.tmp | grep 'i-' | tr -d ',"' | tr -d ' '`
#aws ec2 ${CMD} --profile ${profile} --region ${Region} --instance-ids ${InstanceId}
#rm tmp.tmp