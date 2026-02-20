#!/bin/bash


SG_ID="sg-0bccf4ec7d7823509"
AMI_ID="ami-0220d79f3f480ecf5"
HOSTZONE="Z07387022LPDMR7A449BU"
DOMAIN="Krishsky.online"


for INSTANCENAME in "$@"
do 
    INSTANCEID=$(aws ec2 run-instances \
        --image-id $AMI_ID \
        --instance-type t3.micro \
        --security-group-ids $SG_ID \
        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$INSTANCENAME}]" \
        --query 'Instances[0].InstanceId' \
        --output text)

        aws ec2 wait instance-status-ok --instance-ids $INSTANCEID
    
    if [ "$INSTANCENAME" = "frontend" ]; then
        IP=$(aws ec2 describe-instances \
        --instance-ids $INSTANCEID \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)   
        
        RECORDNAME="$DOMAIN"

    else
        IP=$( aws ec2 describe-instances \
        --instance-ids $INSTANCEID \
        --query 'Reservations[0].Instances[0].PrivateIpAddress' \
        --output text )  
        echo "PV ip is $IP" 
    
        RECORDNAME="$INSTANCENAME"."$DOMAIN"

    fi
    
    echo "IP address : $IP"
    aws route53 change-resource-record-sets \
    --hosted-zone-id $HOSTZONE \
    --change-batch ' 
                {
            "Comment": "Updating a record",
            "Changes": [
                {
                "Action": "UPSERT",
                "ResourceRecordSet": {
                    "Name": "'$RECORDNAME'",
                    "Type": "A",
                    "TTL": 1,
                    "ResourceRecords": [
                    {
                        "Value": "'$IP'"
                    }
                    ]
                }
                }
            ]
            }'

            echo "record updated for the $INSTANCENAME"
done


