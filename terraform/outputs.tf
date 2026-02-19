output "gateway_id" {
  description = "Confluent PNI gateway ID"
  value       = module.pni_hub.confluent_pni_hub_gateway_id
}

output "sandbox_pni_access_point_id" {
  description = "Confluent PNI access point ID"
  value       = module.sandbox_pni_spoke.vpc_pni_access_point_id
}

output "sandbox_pni_security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = module.sandbox_pni_spoke.vpc_pni_security_group_id
}

output "sandbox_pni_eni_ids" {
  description = "All ENI IDs (for reference/debugging)"
  value       = module.sandbox_pni_spoke.vpc_pni_eni_ids
}

output "shared_pni_access_point_id" {
  description = "Confluent PNI access point ID"
  value       = module.shared_pni_spoke.vpc_pni_access_point_id
}

output "shared_pni_security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = module.shared_pni_spoke.vpc_pni_security_group_id
}

output "shared_pni_eni_ids" {
  description = "All ENI IDs (for reference/debugging)"
  value       = module.shared_pni_spoke.vpc_pni_eni_ids
}
