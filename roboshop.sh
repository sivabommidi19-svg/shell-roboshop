#!bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-081c885356ebfe00e" #replace with your sg ID

for instance in $@
do 

    Instance_Id=$(aws ec2 run-instances --image-id ami-09c813fb71547fc4f --instance-type t3.micro --security-group-ids sg-081c885356ebfe00e --count 1 --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get Private IP
    if [ $instance !m "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids i-0cb9fbed16c8f96bb --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)	

    else
        IP=$(aws ec2 describe-instances --instance-ids i-0cb9fbed16c8f96bb --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
    fi

    echo "$instance: $IP"
done