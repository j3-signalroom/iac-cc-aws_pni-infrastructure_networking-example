
resource "confluent_gateway" "pni" {
  display_name = "${data.confluent_environment.pni.display_name}-pni-gateway"

  environment {
    id = data.confluent_environment.pni.id
  }

  aws_private_network_interface_gateway {
    region = data.aws_region.current.name
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
resource "confluent_access_point" "pni" {
  display_name = "ccloud-pni-${local.network_id}"

  environment {
    id = data.confluent_environment.pni.id
  }

  gateway {
    id = confluent_gateway.pni.id
  }

  aws_private_network_interface {
    network_interfaces = aws_network_interface.pni[*].id
    account            = data.aws_caller_identity.current.account_id
  }

  depends_on = [
    aws_network_interface.pni
  ]
}
