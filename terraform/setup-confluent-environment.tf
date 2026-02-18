resource "confluent_environment" "non_prod" {
  display_name = "non-prod"

  stream_governance {
    package = "ESSENTIALS"
  }
}

resource "confluent_gateway" "non_prod" {
  display_name = "${confluent_environment.non_prod.display_name}-pni-gateway"

  environment {
    id = confluent_environment.non_prod.id
  }

  aws_private_network_interface_gateway {
    region = var.aws_region
    zones  = local.available_zone_ids
  }

  depends_on = [ 
    confluent_environment.non_prod 
  ]
}
