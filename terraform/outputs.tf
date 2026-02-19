output "confluent_pni_hub_gateway_id" {
  description = "Confluent PNI hub gateway ID"
  value       = module.pni_hub.confluent_pni_hub_gateway_id
}

output "confluent_pni_hub_access_point_id" {
  description = "Confluent PNI hub access point ID"
  value       = module.pni_hub.confluent_pni_hub_access_point_id
}

output "confluent_environment_id" {
  description = "Confluent Cloud Environment ID"
  value       = confluent_environment.non_prod.id
} 

output "confluent_sandbox_kafka_cluster_id" {
  description = "Confluent Cloud Sandbox Kafka Cluster ID"
  value       = confluent_kafka_cluster.sandbox_cluster.id
}

output "confluent_shared_kafka_cluster_id" {
  description = "Confluent Cloud Shared Kafka Cluster ID"
  value       = confluent_kafka_cluster.shared_cluster.id
}