output "vpc_id" {
  description = "VPC ID for the PNI VPC"
  value       = aws_vpc.pni.id
}

output "vpc_cidr" {
  description = "CIDR block of the PNI VPC"
  value       = aws_vpc.pni.cidr_block
}

output "subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "eni_ids" {
  description = "List of PNI ENI IDs"
  value       = aws_network_interface.pni[*].id
}

output "eni_private_ips" {
  description = "Private IPs assigned to PNI ENIs (one per AZ)"
  value       = [for eni in aws_network_interface.pni : eni.private_ip]
}

output "access_point_id" {
  description = "Confluent PNI Access Point ID"
  value       = confluent_access_point.pni.id
}

output "security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = aws_security_group.pni.id
}

output "availability_zone_ids" {
  description = "AZ IDs (universal) where ENIs are deployed"
  value       = local.available_zone_ids
}

output "vpc_subnet_details" {
  description = "Map of subnet details by index"
  value = {
    for i, subnet in aws_subnet.private : i => {
      subnet_id            = subnet.id
      availability_zone    = subnet.availability_zone
      availability_zone_id = local.available_zone_ids[i]
      cidr_block           = subnet.cidr_block
      eni_id               = aws_network_interface.pni[i].id
      eni_private_ip       = aws_network_interface.pni[i].private_ip
    }
  }
}
