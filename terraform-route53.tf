# Route 53 Hosted Zone and Records
resource "aws_route53_zone" "main" {
  name = "unconvensionalweb.com"

  tags = {
    Name = "mern-app-zone"
  }
}

# SSL Certificate for domain
resource "aws_acm_certificate" "ssl_cert" {
  domain_name               = "unconvensionalweb.com"
  subject_alternative_names = ["*.unconvensionalweb.com"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "mern-ssl-cert"
  }
}

# Certificate validation records
resource "aws_route53_record" "cert_validation" {
  for_each = {
    for dvo in aws_acm_certificate.ssl_cert.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = aws_route53_zone.main.zone_id
}

# Certificate validation
resource "aws_acm_certificate_validation" "ssl_cert" {
  certificate_arn         = aws_acm_certificate.ssl_cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
}

# DNS records will be created manually after getting load balancer DNS
# Run: kubectl get svc frontend -n mern-app
# Then update DNS records in Route 53 console or via CLI

# Outputs
output "route53_zone_id" {
  value = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  value = aws_route53_zone.main.name_servers
}

output "ssl_certificate_arn" {
  value = aws_acm_certificate.ssl_cert.arn
}