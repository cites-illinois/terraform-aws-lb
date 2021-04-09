# TODO: We currently support only application and network. This needs to be
# documented and validated.

locals {
  security_groups = local.is_alb ? concat(var.security_groups, [aws_security_group.default[0].id]) : null
}

# TODO: EIP is apparently needed for NLBs, which implies that this IP is
# public. Figure out more about this.

# FIXME: For an NLB, create one EIP for each subnet in this tier.
# First, is this # necessary?
# Second, note that this code will need modification for internal ELBs.

resource "aws_eip" "default" {
  for_each = local.is_nlb ? toset(data.aws_subnet_ids.selected.ids) : toset()
  tags     = merge({ Name = var.name }, var.tags)
}

resource "aws_lb" "default" {
  name            = var.name
  internal        = var.internal
  security_groups = local.security_groups
  subnets         = local.is_alb ? data.aws_subnet_ids.selected.ids : null

  dynamic "subnet_mapping" {
    for_each = local.is_nlb ? toset(data.aws_subnet_ids.selected.ids) : toset()
    content {
      subnet_id     = subnet_mapping.value
      allocation_id = aws_eip.default[subnet_mapping.value].id
    }
  }

  idle_timeout       = var.idle_timeout
  load_balancer_type = var.load_balancer_type

  # FIXME: This needs to be reviewed.
  dynamic "access_logs" {
    # for_each = [var.access_logs]
    for_each = var.access_logs
    content {
      bucket  = lookup(each.value, "bucket")
      enabled = lookup(each.value, "enabled", false)
      prefix  = lookup(each.value, "prefix", null)
    }
  }

  # FIXME: Need to address the case wherein var.access_logs is empty.
  #
  # access_logs {
  #   bucket  = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  #   prefix  = "lb"
  #   enabled = true
  # }

  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2

  tags = var.tags
}
