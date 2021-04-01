output "arn" {
  description = "Load balancer ARN."
  value       = aws_lb.default.arn
}

output "arn_suffix" {
  description = "ARN suffix for use with CloudWatch metrics."
  value       = aws_lb.default.arn_suffix
}

output "dns_name" {
  description = "DNS name of the load balancer."
  value       = aws_lb.default.dns_name
}

# TODO: Need to figure out why this does not work
#output "canonical_hosted_zone_id" {
#  description = "The canonical hosted zone ID of the load balancer."
#  value       = aws_lb.default.canonical_hosted_zone_id
#}

output "fqdn" {
  description = "Fully qualified domain names."
  value       = aws_route53_record.default.*.fqdn
}

output "listener_arns" {
  description = "Listener ARNs."
  value       = [{ for listener in aws_lb_listener.default : listener.port => listener.arn }]
}

output "security_group_id" {
  description = "Default security group created for the load balancer."
  value       = local.is_alb ? aws_security_group.default[0].id : null
}

output "target_group_arn" {
  description = "Default target group for all created listeners."
  value       = aws_lb_target_group.default.arn
}

output "zone_id" {
  description = "Canonical hosted zone ID of the load balancer (to be used in a Route 53 alias record)."
  value       = aws_lb.default.zone_id
}
