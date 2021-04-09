#
# Recommended security groups 
#
#    https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html
#
resource "aws_security_group" "default" {
  count = local.is_alb ? 1 : 0

  description = format("%s load balancer security group", var.name)
  name        = var.name
  vpc_id      = data.aws_vpc.selected.id
  tags        = merge({ Name = var.name }, var.tags)
}

# TODO: This needs review and refactoring.

resource "aws_security_group" "secure" {
  count = local.is_alb ? length(var.secure_ports) : 0

  description = lookup(
    var.secure_ports[count.index],
    "security_group_description",
    "",
  )
  name   = var.secure_ports[count.index]["security_group"]
  vpc_id = data.aws_vpc.selected.id
  tags   = merge({ Name = var.name }, var.tags)
}

# Allow inbound TCP connections on listener port only.

resource "aws_security_group_rule" "internet_in" {
  # Used for non-internal ALBs.
  for_each = local.is_alb ? (var.internal ? {} : var.ports) : {}

  description       = format("Allow inbound TCP connections to load balancer %s on listener port %d", var.name, each.key)
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default[0].id
}

# Security group rule for internal LBs allows inbound connections from VPC only.

resource "aws_security_group_rule" "vpc_in" {
  for_each = local.is_alb ? (var.internal ? var.ports : {}) : {}

  description       = format("Allow inbound TCP connections from VPC %s to %s on listener port %s", var.vpc, var.name, each.key)
  type              = "ingress"
  from_port         = each.key
  to_port           = each.key
  protocol          = "tcp"
  cidr_blocks       = [data.aws_vpc.selected.cidr_block]
  security_group_id = aws_security_group.default[0].id
}

# Allows inbound ICMP traffic.
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group-ingress.html
# https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml

resource "aws_security_group_rule" "allow_icmp" {
  count = local.is_alb ? 1 : 0

  description = format("Allow inbound ICMP traffic to load balancer %s", var.name)
  type        = "ingress"
  from_port   = -1 # Allow any ICMP type number
  to_port     = -1 # Allow any ICMP code
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.default[0].id
}

# Resource to support application specific ports on the internal load balancer
# that are protected by custom security groups so that we can limit access to certain applications

resource "aws_security_group_rule" "port_in" {
  # Used if security_group_ports is specified.
  count = local.is_alb ? length(var.secure_ports) : 0

  description              = "Allow connections to ALB on listener port using the security group"
  type                     = "ingress"
  source_security_group_id = element(aws_security_group.secure.*.id, count.index)
  from_port                = var.secure_ports[count.index]["port"]
  to_port                  = var.secure_ports[count.index]["port"]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default[0].id
}
