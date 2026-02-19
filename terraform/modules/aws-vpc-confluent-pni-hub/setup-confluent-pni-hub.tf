
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

# ===================================================================================
# CONFLUENT PNI ACCESS POINT
# ===================================================================================
#
# The access point registers the ENIs with Confluent Cloud, establishing the private
# connectivity path. This replaces confluent_private_link_attachment_connection.
#
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
    aws_network_interface.pni_hub
  ]
}
