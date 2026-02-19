output "vpc_pni_spoke_id" {
  description = "VPC ID for the PNI VPC"
  value       = aws_vpc.pni_spoke.id
}

output "vpc_pni_spoke_cidr" {
  description = "CIDR block of the PNI VPC"
  value       = aws_vpc.pni_spoke.cidr_block
}

output "vpc_pni_spoke_private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.pni_spoke_private[*].id
}

output "vpc_pni_spoke_security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = aws_security_group.pni_spoke.id
}

output "vpc_pni_spoke_availability_zone_ids" {
  description = "AZ IDs (universal) where ENIs are deployed"
  value       = local.available_zone_ids
}

output "vpc_pni_spoke_subnet_details" {
  description = "Map of subnet details by index"
  value = {
    for i, subnet in aws_subnet.pni_spoke_private : i => {
      subnet_id            = subnet.id
      availability_zone    = subnet.availability_zone
      availability_zone_id = local.available_zone_ids[i]
      cidr_block           = subnet.cidr_block
    }
  }
}
