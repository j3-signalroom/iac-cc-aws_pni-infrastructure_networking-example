output "confluent_pni_hub_gateway_id" {
  description = "Confluent PNI hub gateway ID"
  value       = module.pni_hub.confluent_pni_hub_gateway_id
}

output "confluent_pni_hub_access_point_id" {
  description = "Confluent PNI hub access point ID"
  value       = module.pni_hub.confluent_pni_hub_access_point_id
}
