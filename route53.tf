resource "aws_route53_record" "default" {
  count = length(var.alias)

  zone_id = element(data.aws_route53_zone.selected.*.zone_id, count.index)
  name    = var.alias[count.index]["hostname"]
  type    = "A"

  alias {
    name                   = aws_lb.default.dns_name
    zone_id                = aws_lb.default.zone_id
    evaluate_target_health = true
  }
}
