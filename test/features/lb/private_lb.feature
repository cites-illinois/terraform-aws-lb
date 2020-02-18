Feature: Test a basic tfvars configuration for the lb module with a private tier.
    
    Background:
        Given the following variables
            | key  | value                       |
            #------|-----------------------------|
            | name | behave-test-lb-${random:10} |

    Scenario: Initialize testing for lb module with a private tier.
        
        Given terraform module 'lb'
            | key             | value                      |
            #-----------------|----------------------------|
            | name            | "${var.name}"              |
            | vpc             | "techservicesasdrone1-vpc" |
            | tier            | "private"                  |
            | internal        | "true"                     |

        Given terraform list 'ports'
        Given terraform append map to 'ports' list
            | key      | value   |
            #----------|---------|
            | port     | "443"   |
            | protocol | "HTTPS" |
        
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
            | internal | ${bool:true}  |
