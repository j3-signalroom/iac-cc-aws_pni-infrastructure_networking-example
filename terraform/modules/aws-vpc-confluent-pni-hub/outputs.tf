output "vpc_id" {
  description = "VPC ID for the PNI Hub VPC"
  value       = aws_vpc.pni_hub.id
}

output "vpc_pni_hub_cidr" {
  description = "CIDR block of the PNI Hub VPC"
  value       = aws_vpc.pni_hub.cidr_block
}

output "vpc_pni_hub_private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.pni_hub[*].id
}

output "vpc_pni_hub_eni_ids" {
  description = "List of PNI Hub ENI IDs"
  value       = aws_network_interface.pni_hub[*].id
}

output "vpc_pni_hub_eni_private_ips" {
  description = "Private IPs assigned to PNI Hub ENIs (one per AZ)"
  value       = [for eni in aws_network_interface.pni_hub : eni.private_ip]
}

output "vpc_pni_hub_access_point_id" {
  description = "Confluent PNI Hub Access Point ID"
  value       = confluent_access_point.pni_hub.id
}

output "vpc_pni_hub_security_group_id" {
  description = "Security group ID attached to PNI Hub ENIs"
  value       = aws_security_group.pni_hub.id
}

output "vpc_pni_hub_availability_zone_ids" {
  description = "AZ IDs (universal) where PNI Hub ENIs are deployed"
  value       = local.available_zone_ids
}

output "vpc_pni_hub_subnet_ids" {
  description = "List of subnet IDs in the PNI Hub VPC"
  value       = aws_subnet.pni_hub[*].id
}

output "confluent_pni_hub_gateway_id" {
  description = "Confluent PNI Hub Gateway ID"
  value       = confluent_gateway.pni_hub.id
}

output "confluent_pni_hub_access_point_id" {
  description = "Confluent PNI Hub Access Point ID"
  value       = confluent_access_point.pni_hub.id
}

output "vpc_pni_hub_subnet_details" {
  description = "Map of subnet details by index"
  value = {
    for i, subnet in aws_subnet.pni_hub : i => {
      subnet_id            = subnet.id
      availability_zone    = subnet.availability_zone
      availability_zone_id = local.available_zone_ids[i]
      cidr_block           = subnet.cidr_block
      eni_id               = aws_network_interface.pni_hub[i].id
      eni_private_ip       = aws_network_interface.pni_hub[i].private_ip
    }
  }
}
