# -------------------------------------------
#  AWS EC2 server batch control by ssh v0.1
# -------------------------------------------
#
#  Required python packages : boto3 , paramiko
#  boto3 : aws connect sdk
#  paramiko : to connect ec2 by ssh
#

# -*-coding: utf-8

import sys
import json
import os
import paramiko
from paramiko import channel
import time
import boto3
from boto3 import client


# Your secret key path
keyPath = "D:\conn/test.pem"
# Your server's user id
user = "ec2-user"
# Involve secret key
key = paramiko.RSAKey.from_private_key_file(keyPath)

print("-----------Start Script------------------")

# To connect server by ssh 
def connSsh(instance_info):
    keyPath = "D:\conn/test.pem"
    user = "ec2-user"
    key = paramiko.RSAKey.from_private_key_file(keyPath)
    hosts = []

    remoteCommand = "hostname ; date ; w \n"

    # create hosts array to connect a host-ipaddress.
    for i in instance_info:
        if i[2] != 'None':
            hosts.append(i[2])

    for host in hosts:
        print("==== Connecting : ",host)
        cli = paramiko.SSHClient()
        cli.set_missing_host_key_policy(paramiko.AutoAddPolicy)
        cli.connect(hostname = host, username = user, pkey = key)

        # Create New interactive shell
        channel = cli.invoke_shell()

        # To send command
        channel.send(remoteCommand)
        time.sleep(1.0)

        # Return result
        output = channel.recv(65535).decode("utf-8")
        print(output)
        cli.close()

# To describe a instance
def describe_instances(client):
    response = client.describe_instances(
        Filters=[
            {
                'Name': 'tag:Name',
                'Values': [
                    'mama_prd_webwas_1',
                    'mama_prd_webwas_2',
                    'mama_prd_webwas_ASG'
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
            tagName = instance['Tags']
            ret = next((item for item in tagName if item['Key'] == 'Name'),None)
            if 'PrivateIpAddress' in instance: 
                privateIp = instance['PrivateIpAddress']
            else:
                privateIp = "None"

            result_describe_instance = [
                ret['Value'],
                instance['InstanceId'],
                privateIp,
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
    # Presentation instance infomation and state
    print("---"*27)
    print("Name\t\t\tInstanceID\t\tPrivateIP\tState")
    print("---"*27)
    for info in instance_info:
        print(info[0]+"\t"+info[1]+"\t"+info[2]+"\t"+info[3])
    print("---"*27)

    state = []
    for y in instance_info:
        state.append(y[3])
    
    runCount = state.count('running')

    print("* Total Instances : ",len(instance_info))
    print("* Running Instances : ",runCount)

def main():
    # Connect aws
    connection = connect_aws()
    instance_info = describe_instances(connection)
    viewer(instance_info)
    print ("")
    print ("========== Connect Server ===============")
    connSsh(instance_info)

if __name__ == "__main__":
    main()
