Feature: Test different tfvars configurations for the lb module with a public tier.
    
    
    Background: Initialize testing for lb module with a public tier.

        Given the following variables
            | key  | value                       |
            #------|-----------------------------|
            | name | behave-test-lb-${random:10} |

        Given terraform module 'lb'
            | key  | value                      |
            #------|----------------------------|
            | name | "${var.name}"              |
            | vpc  | "techservicesasdrone1-vpc" |
            | tier | "public"                   |
        
        Given terraform list 'ports'
        Given terraform append map to 'ports' list
            | key      | value   |
            #----------|---------|
            | port     | "443"   |
            | protocol | "HTTPS" |
    
    
    Scenario: Public lb with 1 port
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | default     |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: Public lb with 2 ports
        
        Given terraform append map to 'ports' list
            | key      | value  |
            #----------|--------|
            | port     | "80"   |
            | protocol | "HTTP" |
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | default     |       |
            |        | aws_lb_listener         | default     |   2   |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |   2   |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: Adding access logs substitutes aws_lb "default" with aws_lb "user"
        
        Given terraform map 'access_logs'
            | key    | value    |
            #--------|----------|
            | bucket | "foobar" |
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | user        |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: Adding an empty access log map does not change the plan
        
        Given terraform map 'access_logs'
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | default     |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: Disabling access logs
        
        Given terraform map 'access_logs'
            | key     | value   |
            #---------|---------|
            | bucket  | ""      |
            | enabled | "false" |
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | user        |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: Adding a security group does not change the default plan
        
        Given terraform list 'security_groups'
            | sgs          |
            #--------------|
            | "fake-sg-id" |
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | default     |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
    
    
    Scenario: If internal == True, use aws_security_group_rule vpc_in over internet_in
        Given terraform tfvars
            | varname                    | value             |
            #----------------------------|-------------------|
            | internal                   | "true"            |
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name       | count |
            #--------|-------------------------|------------|-------|
            | create | aws_lb                  | default    |       |
            |        | aws_lb_listener         | default    |       |
            |        | aws_lb_target_group     | default    |       |
            |        | aws_security_group      | default    |       |
            |        | aws_security_group_rule | vpc_in     |       |
            |        | aws_security_group_rule | allow_icmp |       |
        
        Then terraform resource 'aws_lb' 'default' has changed attributes
            | attr     | value         |
            #----------|---------------|
            | internal | ${bool:True}  |
    
    
    Scenario Outline: Changing default values for optional variables
        
        Given terraform tfvars
            | varname                    | value               |
            #----------------------------|---------------------|
            | enable_deletion_protection | "true"              |
            | enable_http2               | "false"             |
            | idle_timeout               | "100"               |
            | ip_address_type            | "<ip_address_type>" |
        Given terraform list 'alias'
        Given terraform append map to 'alias' list
            | attr     | value                               |
            #----------|-------------------------------------|
            | domain   | "as-drone.techservices.illinois.edu" |
            | hostname | "lb"                                |
        Given terraform map 'tags'
            | tagname | value |
            #---------|-------|
            | foo     | "bar" |
        
        When we run terraform plan
        
        Then terraform plans to perform these exact resource actions
            | action | resource                | name        | count |
            #--------|-------------------------|-------------|-------|
            | create | aws_lb                  | default     |       |
            |        | aws_lb_listener         | default     |       |
            |        | aws_lb_target_group     | default     |       |
            |        | aws_security_group      | default     |       |
            |        | aws_security_group_rule | internet_in |       |
            |        | aws_security_group_rule | allow_icmp  |       |
            |        | aws_route53_record      | default     |       |
            
        Then terraform resource 'aws_lb' 'default' has changed attributes
            | attr                       | value             |
            #----------------------------|-------------------|
            | enable_deletion_protection | ${bool:True}              |
            | enable_http2               | ${bool:False}             |
            | idle_timeout               | ${int:100}               |
            | ip_address_type            | <ip_address_type> |
        
        Examples: Different ip address types
            | ip_address_type |
            #-----------------|
            | dualstack       |
            | ipv4            |
