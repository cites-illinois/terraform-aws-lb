# lb

[![Terraform actions status](https://github.com/techservicesillinois/terraform-aws-lb/workflows/terraform/badge.svg)](https://github.com/techservicesillinois/terraform-aws-lb/actions)

Provides a load balancer, which may be either an application or
network load balancers.

Example Usage
-----------------

### Public load balancer
```hcl
module "lb_name" {
  source = "git@github.com:techservicesillinois/terraform-aws-lb"

  name = "lb_name"
  tier = "public"
  vpc  = "vpc_name"

  alias = [
    {
      hostname = "mylb"
      domain   = "example.com"
    },
    {
      hostname = "lb"
      domain   = "alternate.com"
    }
  ]

  ports = {
    443 = {
      protocol = "HTTPS"
    },

    80 = {
      protocol = "HTTP"
    }
  }

  certificate_arn  = "certificate_arn"
  ssl_policy       = "ssl_policy_name"
}
```

### Private load balancer
```hcl
module "lb_name" {
  source = "git@github.com:techservicesillinois/terraform-aws-lb"

  name     = "lb_name"
  internal = true

  tier     = "nat"
  vpc      = "vpc_name"

  alias = [
    {
      hostname = "mylb"
      domain   = "example.com"
    }
  ]

  ports = [
    {
      port             = "port_number"
      protocol         = "protocol_name"
      certificate_arn  = "certificate_arn"
      ssl_policy       = "ssl_policy_name"
    }
  ]
}
```


Argument Reference
-----------------

The following arguments are supported:

* `name` - (Required) The name of the LB. This name must be unique
within your AWS account, can have a maximum of 32 characters, must
contain only alphanumeric characters or hyphens, and must not begin
or end with a hyphen.

* `vpc` - (Required) The name of the virtual private cloud to be
associated with the load balancer.

* `tier` - (Required) A subnet tier tag (e.g., public, private,
nat) to determine subnets to be associated with the load balancer.

* `ports` - (Required) A list of [Ports](#ports) blocks. Ports
documented below.

* `internal` - (Optional) If true, the LB will be internal.

* `security_groups` - (Optional) A list of security group names to
assign to the load balancer.

* `access_logs` - (Optional) An [Access Logs](#access_logs) block.
Access Logs documented below.

* `idle_timeout` - (Optional) The time in seconds that the connection
is allowed to be idle. Default: 60.

* `enable_deletion_protection` - (Optional) If true, deletion of
the load balancer will be disabled via the AWS API. This will prevent
Terraform from deleting the load balancer. Defaults to false.

* `enable_http2` - (Optional) Indicates whether HTTP/2 is enabled
in application load balancers. Defaults to true.

* `ip_address_type` - (Optional) The type of IP addresses used by
the subnets for your load balancer. The possible values are ipv4
and dualstack.

* `tags` - (Optional) A mapping of tags to assign to the resource.

* `alias` - (Optional) A list of [Alias](#alias) blocks. Alias
documented below.

`access_logs`
-------

Access Logs (access_logs) supports the following:

* `bucket` - (Required) The S3 bucket name to store the logs in.

* `prefix` - (Optional) The S3 bucket prefix. Logs are stored in
the root if not configured.

* `enabled` - (Optional) Boolean to enable / disable access_logs.
Defaults to false, even when bucket is specified.

`alias`
-------

Alias supports the following:

* `domain` - (Required) The domain name of the hosted zone to contain
this record.

* `hostname` - (Required) The name of the route53 record.

`ports`
-------

Ports supports the following:

* `port` - (Required) A port on which the load balancer is listening

* `protocol` - (Required) The protocol for connections from clients
to the load balancer. Valid values are TCP, HTTP and HTTPS.

* `ssl_policy` - (Optional) The name of the SSL Policy for the
listener. Required if protocol is HTTPS. Defaults to top level
`ssl_policy` value.

* `certificate_arn` - (Optional) The ARN of the default SSL server
certificate. Exactly one certificate is required if the protocol
is HTTPS. For adding additional SSL certificates, see the
[aws_lb_listener_certificate resource](https://www.terraform.io/docs/providers/aws/r/lb_listener_certificate.html).
Defaults to top level `certificate_arn`.

Attributes Reference
--------------------

The following attributes are exported:

* `id` - The ARN of the load balancer (matches `arn`).

* `arn` - The ARN of the load balancer (matches `id`).

* `arn_suffix` - The ARN suffix for use with CloudWatch Metrics.

* `dns_name` - The DNS name of the load balancer.

* `zone_id` - The canonical hosted zone ID of the load balancer (to
be used in a Route 53 Alias record).

* `listener_arns` - The ARNs of the listeners.

* `security_group_id` - The ID of the security group rule.

* `target_group_arn` - The ARN of the Target Group.

* `fqdn` - A list of FQDNs built using the corresponding zone
`domain` and `hostname`.

Credits
--------------------

**Nota bene** the vast majority of the verbiage on this page was
taken directly from the Terraform manual, and in a few cases from
Amazon's documentation.
