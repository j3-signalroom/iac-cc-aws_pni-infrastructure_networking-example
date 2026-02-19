# ===================================================================================
# VPC AND PRIVATE SUBNETS
# ===================================================================================
resource "aws_vpc" "pni_hub" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-confluent-pni-hub-${data.confluent_environment.pni_hub.display_name}"
  }
}

resource "aws_subnet" "pni_hub" {
  count = var.subnet_count

  vpc_id            = aws_vpc.pni.id
  cidr_block        = cidrsubnet(var.vpc_cidr, var.new_bits, count.index)
  availability_zone = local.available_zones[count.index]

  tags = {
    Name          = "confluent-pni-hub-${data.confluent_environment.pni_hub.display_name}-subnet-${count.index + 1}"
    AvailableZone = local.available_zones[count.index]
    AZ_ID         = local.available_zone_ids[count.index]
  }
}

# Route table per subnet
resource "aws_route_table" "pni_hub" {
  count = var.subnet_count
  
  vpc_id = aws_vpc.pni_hub.id
  
  tags = {
    Name = "confluent-pni-hub-${data.confluent_environment.pni_hub.display_name}-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "pni_hub" {
  count = var.subnet_count

  subnet_id      = aws_subnet.pni_hub[count.index].id
  route_table_id = aws_route_table.pni_hub[count.index].id
}

# ============================================================================
# TRANSIT GATEWAY ATTACHMENT
# ============================================================================
resource "aws_ec2_transit_gateway_vpc_attachment" "pni_hub" {
  subnet_ids         = aws_subnet.pni_hub[*].id
  transit_gateway_id = var.tgw_id
  vpc_id             = aws_vpc.pni_hub.id
  
  # Enable DNS support for cross-VPC resolution
  dns_support = "enable"

  tags = {
    Name        = "${aws_vpc.pni_hub.id}-ccloud-pni-tgw-attachment"
    Environment = data.confluent_environment.pni_hub.display_name
    ManagedBy   = "Terraform Cloud"
    Purpose     = "Confluent PNI connectivity"
  }
}

# Associate with Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_association" "pni_hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.pni_hub.id
  transit_gateway_route_table_id = var.tgw_rt_id
}

resource "aws_ec2_transit_gateway_route_table_propagation" "pni_hub" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.pni_hub.id
  transit_gateway_route_table_id = var.tgw_rt_id
}

# ============================================================================
# ROUTES: PNI HUB VPC <-> TFC AGENT VPC
# ============================================================================
resource "aws_route" "pni_hub_to_tfc_agent" {
  count = var.subnet_count

  route_table_id         = aws_route_table.pni_hub[count.index].id
  destination_cidr_block = var.tfc_agent_vpc_cidr
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.pni_hub
  ]
}

resource "aws_route" "tfc_agent_to_pni_hub" {
  count = length(var.tfc_agent_vpc_rt_ids) > 0 ? length(var.tfc_agent_vpc_rt_ids) : 0
  
  route_table_id         = element(var.tfc_agent_vpc_rt_ids, count.index)
  destination_cidr_block = aws_vpc.pni_hub.cidr_block
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.pni_hub
  ]
}

# ============================================================================
# ROUTES: PNI HUB VPC <-> VPN VPC + VPN CLIENTS
# ============================================================================
resource "aws_route" "pni_hub_to_vpn_client" {
  count = var.subnet_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = var.vpn_client_vpc_cidr
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.pni_hub
  ]
}

resource "aws_route" "pni_hub_to_vpn_vpc" {
  count = var.subnet_count

  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = var.vpn_vpc_cidr
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.pni_hub
  ]
}

resource "aws_route" "vpn_to_pni_hub" {
  count = length(var.vpn_vpc_rt_ids) > 0 ? length(var.vpn_vpc_rt_ids) : 0
  
  route_table_id         = element(var.vpn_vpc_rt_ids, count.index)
  destination_cidr_block = aws_vpc.pni_hub.cidr_block
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.pni_hub
  ]
}

# ============================================================================
# CLIENT VPN ROUTES TO PNI HUB VPC
# ============================================================================
resource "aws_ec2_client_vpn_route" "to_pni_hub" {
  count = var.vpn_endpoint_id != null ? length(var.vpn_target_subnet_ids) : 0

  client_vpn_endpoint_id = var.vpn_endpoint_id
  destination_cidr_block = aws_vpc.pni_hub.cidr_block
  target_vpc_subnet_id   = var.vpn_target_subnet_ids[count.index]
}

resource "aws_ec2_client_vpn_authorization_rule" "to_pni_hub" {
  count = var.vpn_endpoint_id != null ? 1 : 0

  client_vpn_endpoint_id = var.vpn_endpoint_id
  target_network_cidr    = aws_vpc.pni_hub.cidr_block
  authorize_all_groups   = true
}
