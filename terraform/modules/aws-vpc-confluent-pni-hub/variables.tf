variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
}

variable "new_bits" {
    description = "New bit"
    type = number
}

variable "confluent_environment_id" {
  description = "Confluent Environment ID"
  type        = string
}

variable "tgw_id" {
  description = "Transit Gateway ID to attach the PrivateLink VPC to"
  type        = string
} 

variable "tgw_rt_id" {
  description = "Transit Gateway Route Table ID to associate the PrivateLink VPC attachment with"
  type        = string
}

variable "vpn_client_vpc_cidr" {
  description = "VPN Client VPC CIDR"
  type        = string
}

variable "tfc_agent_vpc_id" {
  description = "Terraform Cloud Agent VPC ID (for tagging PHZ association purposes)"
  type        = string
}

variable "tfc_agent_vpc_cidr" {
  description = "Terraform Cloud Agent VPC CIDR"
  type        = string
}

variable "vpn_vpc_cidr" {
  description = "VPN VPC CIDR"
  type        = string
}

variable "vpn_vpc_id" {
  description = "VPN VPC ID (for tagging PHZ association purposes)"
  type        = string
}

variable "tfc_agent_vpc_rt_ids" {
  description = "List of Terraform Cloud Agent VPC Route Table IDs to associate with the Transit Gateway attachment"
  type        = list(string)
}

variable "vpn_vpc_rt_ids" {
  description = "List of VPN VPC Route Table IDs to associate with the Transit Gateway attachment"
  type        = list(string)
}

variable "vpn_endpoint_id" {
  description = "VPN Endpoint ID for adding routes to PrivateLink VPCs"
  type        = string
  default     = null
}

variable "vpn_target_subnet_ids" {
  description = "List of VPN associated subnet IDs to create routes through"
  type        = list(string)
  default     = []
}

variable "eni_number_per_subnet" {
  description = "Number of ENIs to create per subnet"
  type        = number
  default     = 17
}

variable "tags" {
  description = "Tags applied to all resources"
  type        = map(string)
  default     = {}
}
