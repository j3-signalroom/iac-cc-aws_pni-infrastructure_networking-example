# The gateway is a cloud-native Kafka proxy solution designed to simplify connectivity to and from 
# Confluent Cloud Kafka cluster services.  It provides a secure and efficient way to connect your
# applications and services to Confluent Cloud, enabling seamless integration and communication with
# your Kafka clusters (i.e., abstracting away complex broker lists, inconsistent security settings,
# and the operational overhead of managing direct client-to-cluster connections).
resource "confluent_gateway" "pni_hub" {
  display_name = "${data.confluent_environment.pni_hub.display_name}-pni-hub-gateway"

  environment {
    id = data.confluent_environment.pni_hub.id
  }

  aws_private_network_interface_gateway {
    region = data.aws_region.current.id
    zones  = local.available_zone_ids
  }
}

# The access point is the connection instance to the gateway.  It registers the ENIs with Confluent Cloud, 
# establishing the private connectivity path.
resource "confluent_access_point" "pni_hub" {
  display_name = "ccloud-pni-hub-${local.network_id}"

  environment {
    id = data.confluent_environment.pni_hub.id
  }

  gateway {
    id = confluent_gateway.pni_hub.id
  }

  aws_private_network_interface {
    network_interfaces = [for eni in aws_network_interface.pni_hub : eni.id]
    account            = data.aws_caller_identity.current.account_id
  }

  depends_on = [
    aws_network_interface.pni_hub,
    aws_network_interface_permission.pni_hub
  ]
}
