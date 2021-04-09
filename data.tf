data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = var.tier
  }
}

data "aws_route53_zone" "selected" {
  count = length(var.alias)

  name   = var.alias[count.index]["domain"]
  vpc_id = var.internal ? data.aws_vpc.selected.id : null
}

# TODO: We currently support only application and network. This needs to be
# documented and validated.

locals {
  is_alb            = (var.load_balancer_type == "application") ? true : false
  is_nlb            = (var.load_balancer_type == "network") ? true : false
  needs_certificate = local.is_alb && ! var.internal
}

module "lb_certificate" {
  # TODO: Should add count to handle [stupid] case where no aliases exist.
  source = "git@github.com:techservicesillinois/terraform-aws-acm-certificate"

  for_each = local.needs_certificate ? toset([aws_route53_record.default[0].fqdn]) : toset([])
  hostname = var.alias[0]["hostname"]
  domain   = var.alias[0]["domain"]

  # subject_alternative_names = length(local.san) > 0 ? local.san : null
  # subject_alternative_names = local.san
}

# FIXME: Fix this if we ever do a cleanup of subject_alternative_names.
#
#locals {
# san = (length(var.alias) > 1) ? [for a in slice(var.alias, 1, length(var.alias)) : format("%s.%s", a["hostname"], a["domain"])] : []
#}
