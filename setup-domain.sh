#!/bin/bash

echo "🌐 Setting up Route 53 domain..."

# Deploy Route 53 resources
terraform apply -target=aws_route53_zone.main
terraform apply -target=aws_acm_certificate.ssl_cert
terraform apply -target=aws_route53_record.cert_validation
terraform apply -target=aws_acm_certificate_validation.ssl_cert

# Get name servers
echo "📋 Update your domain registrar with these name servers:"
terraform output route53_name_servers

# Get certificate ARN
CERT_ARN=$(terraform output -raw ssl_certificate_arn)
echo "🔒 SSL Certificate ARN: $CERT_ARN"

# Update ingress with certificate
sed -i "s|\${aws_acm_certificate.ssl_cert.arn}|$CERT_ARN|g" k8s/ingress.yaml

echo "✅ Domain setup complete!"
echo "📝 Next steps:"
echo "1. Update your domain registrar with the name servers above"
echo "2. Wait 5-10 minutes for DNS propagation"
echo "3. Deploy your application: kubectl apply -f k8s/"