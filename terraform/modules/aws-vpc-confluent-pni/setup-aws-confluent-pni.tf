# ===================================================================================
# ELASTIC NETWORK INTERFACES (ENIs) FOR PNI
# ===================================================================================
#
# PNI places ENIs directly into your VPC subnets. These ENIs are owned by your AWS
# account but carry traffic to and from Confluent Cloud. This replaces the VPC
# Interface Endpoint used in PrivateLink.
resource "aws_network_interface" "pni" {
  count = var.subnet_count * var.num_eni_per_subnet


  subnet_id = aws_subnet.main[floor(count.index / var.num_eni_per_subnet)].id
  security_groups = [aws_security_group.pni.id]

  # Calculate private IP: base_ip + (j+1) where j is the ENI number within subnet
  # floor(count.index / var.num_eni_per_subnet) gives subnet index (0, 1, 2)
  # count.index % var.num_eni_per_subnet gives ENI index within subnet (0, 1, ...)
  private_ips = [
    cidrhost(
      aws_subnet.main[floor(count.index / var.num_eni_per_subnet)].cidr_block,
      10 + (count.index % var.num_eni_per_subnet) + 1
    )
  ]

  description = "Confluent PNI Subnet ${floor(count.index / var.num_eni_per_subnet)} ENI ${(count.index % var.num_eni_per_subnet) + 1}"

  tags = {
    Name        = "confluent-pni-subnet-${floor(count.index / var.num_eni_per_subnet)}-eni-${(count.index % var.num_eni_per_subnet) + 1}"
    VPC         = aws_vpc.pni.id
    Environment = data.confluent_environment.pni.display_name
    ManagedBy   = "Terraform Cloud"
    Purpose     = "Confluent PNI connectivity"
  }
}

# Create network interface permissions (equivalent to aws ec2 create-network-interface-permission)
resource "aws_network_interface_permission" "pni" {
  count = length(aws_network_interface.pni)

  network_interface_id = aws_network_interface.pni[count.index].id
  permission           = "INSTANCE-ATTACH"
  aws_account_id       = var.aws_account_id
}

# ===================================================================================
# CONFLUENT PNI ACCESS POINT
# ===================================================================================
#
# The access point registers the ENIs with Confluent Cloud, establishing the private
# connectivity path. This replaces confluent_private_link_attachment_connection.
#
resource "confluent_access_point" "pni" {
  display_name = "ccloud-pni-${local.network_id}"

  environment {
    id = var.confluent_environment_id
  }

  gateway {
    id = var.confluent_gateway_id
  }

  aws_private_network_interface {
    network_interfaces = aws_network_interface.pni[*].id
    account            = var.aws_account_id
  }

  depends_on = [
    aws_network_interface.pni
  ]
}
