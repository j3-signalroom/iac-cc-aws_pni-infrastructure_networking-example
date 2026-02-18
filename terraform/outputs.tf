output "gateway_id" {
  description = "Confluent PNI gateway ID"
  value       = confluent_gateway.non_prod.id
}

output "sandbox_pni_access_point_id" {
  description = "Confluent PNI access point ID"
  value       = module.sandbox_vpc_pni.vpc_pni_access_point_id
}

output "sandbox_pni_security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = module.sandbox_vpc_pni.vpc_pni_security_group_id
}

output "sandbox_pni_eni_ids" {
  description = "All ENI IDs (for reference/debugging)"
  value       = module.sandbox_vpc_pni.vpc_pni_eni_ids
}

output "shared_pni_access_point_id" {
  description = "Confluent PNI access point ID"
  value       = module.shared_vpc_pni.vpc_pni_access_point_id
}

output "shared_pni_security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = module.shared_vpc_pni.vpc_pni_security_group_id
}

output "shared_pni_eni_ids" {
  description = "All ENI IDs (for reference/debugging)"
  value       = module.shared_vpc_pni.vpc_pni_eni_ids
}
