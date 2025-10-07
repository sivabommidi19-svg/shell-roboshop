#!bin/bash

AMI_ID="ami-09c813fb71547fc4f"
SG_ID="sg-081c885356ebfe00e" #replace with your sg ID
Zone_ID="Z009120826G54L5D7TCYM" #replace with your id Z009120826G54L5D7TCYM
DOMAIN_NAME="daws86b.fun"
for instance in $@
do 

    Instance_Id=$(aws ec2 run-instances --image-id $AMI_ID --instance-type t3.micro --security-group-ids $SG_ID --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$instance}]" --query 'Instances[0].InstanceId' --output text)

    #Get Private IP
    if [ $instance != "frontend" ]; then
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query 'Reservations[0].Instances[0].PrivateIpAddress' --output text)
        RECORD_NAME="$instance.$DOMAIN_NAME" #mongodb daws86b.fun

    else
        IP=$(aws ec2 describe-instances --instance-ids $Instance_Id --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
        RECORD_NAME="$DOMAIN_NAME" # daws86b.fun
    fi

    echo "$instance: $IP"

    aws route53 change-resource-record-sets \
    --hosted-zone-id $Zone_ID \
    --change-batch '
    {
        "Comment": "Update record set"
        ,"Changes": [{
        "Action"              : "UPSERT"
        ,"ResourceRecordSet"  : {
            "Name"              : "'$RECORD_NAME'"
            ,"Type"             : "A"
            ,"TTL"              : 1
            ,"ResourceRecords"  : [{
                "Value"         : "'$IP'"
            }]
        }
        }]
    }
    '
done