#!/bin/bash

# ---------------------------------
#
#  ec2 controll script v0.1
#
# 		for private
#
# ---------------------------------

#seoul_region="ap-northeast-2"
tokyo_region="ap-northeast-1"
#oregon_region="us-west-2"
#virginia_region="us-east-1"
#frankfurt_region="eu-central-1"
#ireland_region="eu-west-1"
#singapore_region="ap-southeast-1"

profile="heojoonkeyuser"

function fn_controll()
{ 
	CMD=$1
	Region=$2
	echo "Startup ... ${Region} Instances"
	_InstanceId="aws --profile ${profile} ec2 describe-instances --region ${Region} --query 'Reservations[*].Instances[*].InstanceId' --output json"
    echo ${_InstanceId} > tmp.tmp
    InstanceId=`sh tmp.tmp | grep 'i-' | tr -d ',"' | tr -d ' '`
	aws ec2 ${CMD} --profile ${profile} --region ${Region} --instance-ids ${InstanceId}
    rm tmp.tmp
}

if [ z"$1" == z ] ; then
    echo "------- [ AWS Instance Controll  : [ ${Infra} ] ----------"
    echo " $0 start  (  all instance start : ${Infra} )"
    echo " $0 stop  ( all instance stop : ${Infra} )"
    echo " $0 status "
else
    case ${1} in
	start) echo "Startup process... ${Infra}"
	   fn_controll start-instances ap-northeast-1
	   #fn_controll start-instances ap-northeast-2
	   #fn_controll start-instances us-west-2
	   #fn_controll start-instances us-east-1
	   #fn_controll start-instances eu-west-1
	;;
	stop) echo "Shutdown process... : ${Infra}"
	   fn_controll stop-instances ap-northeast-1
	   #fn_controll stop-instances ap-northeast-2
	   #fn_controll stop-instances us-west-2
	   #fn_controll stop-instances us-east-1 
	   #fn_controll stop-instances eu-west-1
	;;
	status) echo "Shutdown process... : ${Infra}"
	   fn_controll describe-instance-status ap-northeast-1
	;;
	*) echo "[Error] Wrong argument !!"
	   exit
	;;
esac
fi
