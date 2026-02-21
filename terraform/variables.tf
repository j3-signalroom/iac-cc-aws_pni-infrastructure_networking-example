# ===================================================
# CONFLUENT CLOUD CONFIGURATION
# ===================================================
variable "confluent_api_key" {
  description = "Confluent API Key (also referred as Cloud API ID)."
  type        = string
}

variable "confluent_api_secret" {
  description = "Confluent API Secret."
  type        = string
  sensitive   = true
}

# ===================================================
# AWS PROVIDER CONFIGURATION
# ===================================================
variable "aws_region" {
    description = "The AWS Region."
    type        = string
}

variable "aws_access_key_id" {
    description = "The AWS Access Key ID."
    type        = string
    default     = ""
}

variable "aws_secret_access_key" {
    description = "The AWS Secret Access Key."
    type        = string
    default     = ""
}

variable "aws_session_token" {
    description = "The AWS Session Token."
    type        = string
    default     = ""
}

variable "aws_account_id" {
    description = "The AWS Account ID."
    type        = string
    default     = ""
}

# ===================================================
# TERRAFORM CONFIGURATION
# ===================================================
variable "tfc_agent_vpc_id" {
  description = "Terraform Cloud Agent VPC ID (for tagging PHZ association purposes)"
  type        = string
}

variable "tfc_agent_vpc_rt_ids" {
  description = "Comma-separated list of Terraform Cloud Agent VPC Route Table IDs to associate with the Transit Gateway attachment"
  type        = string
}

# ===================================================
# TRANSIT GATEWAY CONFIGURATION
# ===================================================
variable "tgw_id" {
  description = "Transit Gateway ID to attach the PrivateLink VPC to"
  type        = string
} 

variable "tgw_rt_id" {
  description = "Transit Gateway Route Table ID to associate the PrivateLink VPC attachment with"
  type        = string
}

# ===================================================
# VPN VPC CONFIGURATION
# ===================================================
variable "vpn_vpc_id" {
  description = "VPN Client VPC ID - Private Hosted Zones will be associated with this VPC"
  type        = string
}

variable "vpn_vpc_rt_ids" {
  description = "Comma-separated list of VPN Client VPC Route Table IDs to associate with the Transit Gateway attachment"
  type        = string
}

variable "vpn_endpoint_id" {
  description = "VPN Endpoint ID for adding routes to PrivateLink VPCs"
  type        = string
}

variable "vpn_target_subnet_ids" {
  description = "Comma-separated list of VPN associated subnet IDs to create routes through"
  type        = string
}

variable "eni_number_per_subnet" {
  description = "Number of ENIs to create per subnet"
  type        = number
  default     = 17
}

variable "subnet_count" {
  description = "Number of subnets to create"
  type        = number
  default     = 3
}

variable "pni_hub_vpc_cidr" {
  description = "CIDR block for the Confluent PNI Hub VPC"
  type        = string
}