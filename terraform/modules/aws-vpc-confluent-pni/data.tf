data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "confluent_environment" "pni" {
  id = var.confluent_environment_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "selected" {
  count = var.subnet_count
  name  = data.aws_availability_zones.available.names[count.index]
}

locals {
  available_zones    = data.aws_availability_zones.available.names

  # AZ IDs are what Confluent requires (e.g. use1-az1), not AZ names
  available_zone_ids = [for az in data.aws_availability_zone.selected : az.zone_id]

  network_id         = "${data.confluent_environment.pni.display_name}-confluent-pni"

  # Build a flat list of {subnet_id, index} for ENI creation
  # 17 ENIs per subnet, e.g., 3 subnets = 51 total
  eni_assignments = flatten([
    for subnet_idx, subnet_id in aws_subnet.pni[*].id : [
      for eni_idx in range(var.eni_number_per_subnet) : {
        key        = "${subnet_idx}-${eni_idx}"
        subnet_id  = subnet_id
        cidr_block = aws_subnet.pni[subnet_idx].cidr_block
        az         = data.aws_availability_zones.available.names[subnet_idx]
        name       = "confluent-pni-subnet-${subnet_idx + 1}-eni-${eni_idx + 1}"
      }
    ]
  ])

  common_tags = merge(var.tags, {
    ManagedBy   = "Terraform Cloud"
    Environment = data.confluent_environment.pni.display_name
    Purpose     = "Confluent PNI connectivity"
  })
}
