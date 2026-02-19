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
            version = "6.33.0"
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

module "pni_hub" {
  source = "./modules/aws-vpc-confluent-pni-hub"

  #
  confluent_environment_id = confluent_environment.non_prod.id

  #
  vpc_cidr                 = "10.3.0.0/20"
  subnet_count             = 3
  new_bits                 = 4
  eni_number_per_subnet    = var.eni_number_per_subnet
  
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

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id 
  tfc_agent_vpc_rt_ids     = local.tfc_agent_vpc_rt_ids
  tfc_agent_vpc_cidr       = data.aws_vpc.tfc_agent.cidr_block

  depends_on = [ 
    confluent_environment.non_prod
  ]
}

module "sandbox_pni_spoke" {
  source = "./modules/aws-vpc-confluent-pni-spoke"

  pni_hub_vpc_cidr = module.pni_hub.vpc_pni_hub_cidr
  vpc_name           = "sandbox"
  vpc_cidr           = "10.0.0.0/20"
  subnet_count       = 3
  new_bits           = 4
  pni_hub_vpc_rt_ids = module.pni_hub.vpc_pni_hub_subnet_ids
  
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

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id 
  tfc_agent_vpc_rt_ids     = local.tfc_agent_vpc_rt_ids
  tfc_agent_vpc_cidr       = data.aws_vpc.tfc_agent.cidr_block

  depends_on = [ 
    module.pni_hub
  ]
}

module "shared_pni_spoke" {
  source = "./modules/aws-vpc-confluent-pni-spoke"

  pni_hub_vpc_cidr = module.pni_hub.vpc_pni_hub_cidr
  vpc_name                   = "shared"
  vpc_cidr                   = "10.1.0.0/20"
  subnet_count               = 3
  new_bits                   = 4
  pni_hub_vpc_rt_ids         = module.pni_hub.vpc_pni_hub_subnet_ids

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

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id 
  tfc_agent_vpc_rt_ids     = local.tfc_agent_vpc_rt_ids
  tfc_agent_vpc_cidr       = data.aws_vpc.tfc_agent.cidr_block

  depends_on = [ 
    module.pni_hub
  ]
}
