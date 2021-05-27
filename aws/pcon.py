#
#  installed packages
# boto3 , paramiko

# -*-coding: utf-8

import sys
import json
import os
from typing import ValuesView
import paramiko
from paramiko import channel
import getpass
import time
import boto3
from boto3 import client

#keyPath = "D:\conn/test.pem"
#user = "ec2-user"
#key = paramiko.RSAKey.from_private_key_file(keyPath)

# 


print("-----------Start Script------------------")

"""
cli = paramiko.SSHClient()
cli.set_missing_host_key_policy(paramiko.AutoAddPolicy)
cli.connect(hostname = host, username = user, pkey = key)

# Create New interactive shell
channel = cli.invoke_shell()

# To send command
channel.send("ls -al\n")
time.sleep(1.0)

# Return result
output = channel.recv(65535).decode("utf-8")
print(output)

cli.close()
"""

"""
aws ec2 describe-instances `
--query 'Reservations[*].Instances[*].{NetworkInterfaces:PrivateIpAddress,Name:Tags[?Key==`Name`]|[0].Value}' `
--filters Name=tag-value,Values=mama_prd_webwas_1,mama_prd_webwas_2,mama_prd_webwas_ASG `
--output table
"""

# To describe a instance


def describe_instances1():
    response = client.describe_instances(
        Filters=[{'Name': 'tag:Value', 'Values': [
            'GoCD Server', 'GoCD Client1', 'GoCD Client2']}]
    )
    result_describe_instance_all = []
    for reservation in response['Reservations']:
        for instance in reservation['Instances']:
            # This will print will output the value of the Dictionary key Specify
            result_describe_instance = [
                ['Name'], instance['InstanceId'], instance['PrivateIpAddress'], instance['State']]
            result_describe_instance_all.append(result_describe_instance)
    return(result_describe_instance_all)

def describe_instances(client):
    # To getting tag name is mama_prd_webwas1 or mama_prd_webwas2 or mama_prd_webwas_ASG
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'GoCD Server',
                    'GoCD Client1',
                    'GoCD Client2'
                ]
            }
        ],
    )
    # We got all instance infomation.
    # Thare are two document that Reservations and ResponseMetadata.
    # We need to get infomation of Reservations.
    result_describe_instance_all = []
    for reservation in response.get('Reservations'):
        for instance in reservation['Instances']:
            # This will print will output the value of the Dictionary key Specify
            result_describe_instance = [
                instance['Tags'][0].get('Value'),
                instance['InstanceId'],
                instance['PrivateIpAddress'],
                instance['State']['Name']
            ]
            result_describe_instance_all.append(result_describe_instance)
    #print(result_describe_instance_all)
    return(result_describe_instance_all)

# Get connection to AWS
def connect_aws():
    session = boto3.Session()
    client = session.client('ec2')
    return(client)

# Print infomation of instance
def viewer(instance_info):
    """ Presentation instance infomation and state """
    print("---"*27)
    print("Name\t\tInstanceID\t\tPrivateIP\tState")
    print("---"*27)
    for info in instance_info:
        print(info[0]+"\t"+"\t"+info[1]+"\t"+info[2]+"\t"+info[3])
    print("---"*27)
    print(len(instance_info))

def shutdown(var,client):
    # 인스턴스 리스트 객체를 인수로 받음, 인스턴스 아이디는 각 리스트 객체의 1번째에 존재
    for i in range(len(var)):
        instanceID = var[i][1]
        print("stop ... "+ instanceID)
        client.stop_instances(InstanceIds=[instanceID,])

def startup(var,client):
    # 인스턴스 리스트 객체를 인수로 받음, 인스턴스 아이디는 각 리스트 객체의 1번째에 존재
    for i in range(len(var)):
        instanceID = var[i][1]
        print("startup ... "+ instanceID)
        client.start_instances(InstanceIds=[instanceID,])

def main():
    # Connect aws
    client = connect_aws()
    instance_info = describe_instances(client)
    startup(instance_info,client)
    #viewer(instance_info)


if __name__ == "__main__":
    main()