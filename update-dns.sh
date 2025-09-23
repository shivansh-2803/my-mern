#!/bin/bash

echo "🌐 Updating DNS records..."

# Get load balancer DNS
LB_DNS=$(kubectl get svc frontend -n mern-app -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

if [ -z "$LB_DNS" ]; then
    echo "❌ Load balancer not ready yet. Run: kubectl get svc frontend -n mern-app"
    exit 1
fi

echo "📋 Load Balancer DNS: $LB_DNS"

# Get Route 53 zone ID
ZONE_ID=$(terraform output -raw route53_zone_id)

# Create/update DNS records
aws route53 change-resource-record-sets --hosted-zone-id $ZONE_ID --change-batch '{
    "Changes": [
        {
            "Action": "UPSERT",
            "ResourceRecordSet": {
                "Name": "unconvensionalweb.com",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "'$LB_DNS'"}]
            }
        },
        {
            "Action": "UPSERT", 
            "ResourceRecordSet": {
                "Name": "api.unconvensionalweb.com",
                "Type": "CNAME",
                "TTL": 300,
                "ResourceRecords": [{"Value": "'$LB_DNS'"}]
            }
        }
    ]
}'

echo "✅ DNS records updated!"
echo "🌐 Your site: https://unconvensionalweb.com"