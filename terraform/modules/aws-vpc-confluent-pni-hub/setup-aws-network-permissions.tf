resource "aws_network_acl" "pni_hub" {
  vpc_id     = aws_vpc.pni_hub.id
  subnet_ids = aws_subnet.pni_hub[*].id

  tags = merge(local.common_tags, {
    Name = "nacl-confluent-pni-hub-${data.confluent_environment.pni_hub.display_name}"
  })
}

resource "aws_network_acl_rule" "ingress_kafka" {
  network_acl_id = aws_network_acl.pni_hub.id
  rule_number    = 100
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 9092
  to_port        = 9092
}

resource "aws_network_acl_rule" "ingress_https" {
  network_acl_id = aws_network_acl.pni_hub.id
  rule_number    = 110
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 443
  to_port        = 443
}

resource "aws_network_acl_rule" "ingress_ephemeral" {
  network_acl_id = aws_network_acl.pni_hub.id
  rule_number    = 120
  egress         = false
  protocol       = "tcp"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 1024
  to_port        = 65535
}

resource "aws_network_acl_rule" "egress_all" {
  network_acl_id = aws_network_acl.pni_hub.id
  rule_number    = 100
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
}

# ===================================================================================
# ELASTIC NETWORK INTERFACES (ENIs) FOR PNI HUB
# ===================================================================================
#
# PNI places ENIs directly into your VPC subnets. These ENIs are owned by your AWS
# account but carry traffic to and from Confluent Cloud. This replaces the VPC
# Interface Endpoint used in PrivateLink.
resource "aws_network_interface" "pni_hub" {
  for_each = { for eni in local.eni_assignments : eni.key => eni }


  subnet_id = each.value.subnet_id
  security_groups = [aws_security_group.pni_hub.id]

  # Calculate private IP: base_ip + (j+1) where j is the ENI number within subnet
  # floor(count.index / var.eni_number_per_subnet) gives subnet index (0, 1, 2)
  # count.index % var.eni_number_per_subnet gives ENI index within subnet (0, 1, ...)
  private_ips = [
    cidrhost(
      aws_subnet.pni_hub[each.value.subnet_index].cidr_block,
      10 + (each.value.eni_index) + 1
    )
  ]

  description = "Confluent PNI Hub Subnet ${each.value.subnet_id} ENI ${each.value.eni_index + 1}"

  tags = {
    Name        = "confluent-pni-hub-subnet-${each.value.subnet_id}-eni-${each.value.eni_index + 1}"
    VPC         = aws_vpc.pni_hub.id
    Environment = data.confluent_environment.pni_hub.display_name
    ManagedBy   = "Terraform Cloud"
    Purpose     = "Confluent PNI connectivity"
  }
}

# ------------------------------------------------------------------------------
# INSTANCE-ATTACH Permissions
# Grant Confluent's AWS account the ability to attach these ENIs to their VMs
# ------------------------------------------------------------------------------

resource "aws_network_interface_permission" "pni_hub" {
  for_each = aws_network_interface.pni_hub

  network_interface_id = each.value.id
  aws_account_id       = confluent_gateway.pni_hub.aws_private_network_interface_gateway[0].account
  permission           = "INSTANCE-ATTACH"
}
