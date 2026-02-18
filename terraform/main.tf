terraform {
    cloud {
      organization = "signalroom"

        workspaces {
            name = "iac-cc-aws-pni-infrastructure-networking-example"
        }
    }

    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "6.32.0"
        }
        confluent = {
            source  = "confluentinc/confluent"
            version = "2.62.0"
        }
        time = {
            source  = "hashicorp/time"
            version = "~> 0.13.1"
        }
        tfe = {
            source = "hashicorp/tfe"
            version = "~> 0.73.0"
        }
    }
}

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
    zones  = local.available_zones
  }

  depends_on = [ 
    confluent_environment.non_prod 
  ]
}

# ===================================================================================
# VPC AND PNI CONFIGURATIONS
# ===================================================================================
module "sandbox_vpc_pni" {
  source = "./modules/aws-vpc-confluent-pni"

  # AWS provider configuration
  aws_region     = var.aws_region
  aws_account_id = var.aws_account_id

  vpc_name           = "sandbox-${confluent_environment.non_prod.display_name}"
  vpc_cidr           = "10.0.0.0/20"
  subnet_count       = 3
  new_bits           = 4
  num_eni_per_subnet = var.num_eni_per_subnet
  
  # Transit Gateway configuration
  tgw_id                   = var.tgw_id
  tgw_rt_id                = var.tgw_rt_id

  # VPN configuration
  vpn_vpc_id               = var.vpn_vpc_id
  vpn_vpc_rt_ids           = local.vpn_vpc_rt_ids
  vpn_client_vpc_cidr      = data.aws_ec2_client_vpn_endpoint.client_vpn.client_cidr_block
  vpn_vpc_cidr             = data.aws_vpc.vpn.cidr_block
  vpn_endpoint_id          = var.vpn_endpoint_id
  vpn_target_subnet_ids    = local.vpn_target_subnet_ids

  # Confluent Cloud configuration
  confluent_environment_id = confluent_environment.non_prod.id
  confluent_gateway_id     = confluent_gateway.non_prod.id

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id 
  tfc_agent_vpc_rt_ids     = local.tfc_agent_vpc_rt_ids
  tfc_agent_vpc_cidr       = data.aws_vpc.tfc_agent.cidr_block

  depends_on = [ 
    confluent_gateway.non_prod 
  ]
}

module "shared_vpc_pni" {
  source = "./modules/aws-vpc-confluent-pni"

  # AWS provider configuration
  aws_region = var.aws_region
  aws_account_id = var.aws_account_id

  vpc_name           = "shared-${confluent_environment.non_prod.display_name}"
  vpc_cidr           = "10.1.0.0/20"
  subnet_count       = 3
  new_bits           = 4
  num_eni_per_subnet = var.num_eni_per_subnet
  
  # Transit Gateway configuration
  tgw_id                   = var.tgw_id
  tgw_rt_id                = var.tgw_rt_id

  # VPN configuration
  vpn_vpc_id               = var.vpn_vpc_id
  vpn_vpc_rt_ids           = local.vpn_vpc_rt_ids
  vpn_client_vpc_cidr      = data.aws_ec2_client_vpn_endpoint.client_vpn.client_cidr_block
  vpn_vpc_cidr             = data.aws_vpc.vpn.cidr_block
  vpn_endpoint_id          = var.vpn_endpoint_id
  vpn_target_subnet_ids    = local.vpn_target_subnet_ids

  # Confluent Cloud configuration
  confluent_environment_id = confluent_environment.non_prod.id
  confluent_gateway_id     = confluent_gateway.non_prod.id

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id 
  tfc_agent_vpc_rt_ids     = local.tfc_agent_vpc_rt_ids
  tfc_agent_vpc_cidr       = data.aws_vpc.tfc_agent.cidr_block

  depends_on = [ 
    confluent_gateway.non_prod 
  ]
}
