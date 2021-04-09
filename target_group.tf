# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/service-load-balancing.html

# The "depends_on" is needed because of a race condition; see
# issue https://github.com/hashicorp/terraform/issues/12634.
# depends_on = ["aws_lb.default"]

# This is a dummy target_group for the default route for each created
# listener. This is not intended to be used except for delivering
# error messages.
resource "aws_lb_target_group" "default" {
  name        = var.name
  port        = 80
  protocol    = local.is_alb ? "HTTP" : "TCP"
  target_type = "ip"
  vpc_id      = data.aws_vpc.selected.id

  stickiness {
    enabled = local.is_alb
    type    = "lb_cookie"
  }

  tags = merge({ Name = var.name }, var.tags)
}
