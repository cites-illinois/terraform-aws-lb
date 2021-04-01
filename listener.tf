locals {
  # TODO: Make local variables for the Route 53 record FQDN itself.
  certificate_arn = module.certificate[aws_route53_record.default[0].fqdn].arn
}

resource "aws_lb_listener" "default" {
  for_each          = var.ports
  load_balancer_arn = aws_lb.default.arn
  port              = each.key
  protocol          = each.value.protocol
  ssl_policy        = local.needs_certificate && (each.value.protocol == "HTTPS") ? var.ssl_policy : null
  # TODO: Need to remove key for certificate_arn in documentation and code.
  certificate_arn = local.needs_certificate && (each.value.protocol == "HTTPS") ? local.certificate_arn : null

  default_action {
    target_group_arn = aws_lb_target_group.default.arn
    type             = "forward"
  }
}

output "zzz_needs_certificate" {
  value = local.needs_certificate
}

output "zzz_internal" {
  value = var.internal
}

output "zzz_certificate" {
  value = local.certificate_arn
}
