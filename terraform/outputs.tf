# ==============================================================================
# Confluent Cloud Outputs
# ==============================================================================

output "gateway_id" {
  description = "Confluent PNI gateway ID"
  value       = module.pni_gateway.gateway_id
}

output "confluent_aws_account_id" {
  description = "Confluent's AWS account ID (used for ENI attach permissions)"
  value       = module.pni_gateway.confluent_aws_account_id
}

output "access_point_id" {
  description = "Confluent PNI access point ID"
  value       = module.pni_access_point.access_point_id
}

# ==============================================================================
# AWS Outputs
# ==============================================================================

output "eni_count" {
  description = "Total number of ENIs created"
  value       = module.pni_enis.eni_count
}

output "security_group_id" {
  description = "Security group ID attached to PNI ENIs"
  value       = module.pni_enis.security_group_id
}

output "eni_ids" {
  description = "All ENI IDs (for reference/debugging)"
  value       = module.pni_enis.eni_ids
}

# ==============================================================================
# Summary
# ==============================================================================

output "pni_summary" {
  description = "Summary of the PNI deployment"
  value = {
    confluent = {
      gateway_id       = confluent_gateway.non_prod.id
      access_point_id  = module.pni_access_point.access_point_id
      environment_id   = confluent_environment.non_prod.id
      aws_region       = var.aws_region
    }
  }
}
