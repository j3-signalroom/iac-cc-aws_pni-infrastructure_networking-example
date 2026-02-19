# ===================================================================================
# PNI SPOKE SECURITY GROUP
# ===================================================================================
#
# Security group attached to the PNI SPOKE ENIs. Controls what traffic can flow between
# your VPCs and Confluent Cloud.
#
# Key differences from the PrivateLink security group:
#   - Port 53 (DNS) rules are REMOVED — Confluent manages DNS for PNI
#   - Default egress (0.0.0.0/0) is REMOVED — emulates PrivateLink's unidirectional
#     behavior per Confluent's recommendation, preventing Confluent-initiated
#     connections into your network
#   - All rules are inline to allow Terraform to revoke the default egress rule
#
resource "aws_security_group" "pni_spoke" {
  name        = "ccloud-pni-spoke-${local.network_id}-${aws_vpc.pni_spoke.id}"
  description = "Confluent Cloud PNI Security Group for ${var.vpc_name}"
  vpc_id      = aws_vpc.pni_spoke.id

  # -----------------------------------------------------------------------
  # INGRESS: HTTPS (443) — Confluent REST API, Schema Registry, admin
  # -----------------------------------------------------------------------
  ingress {
    description = "HTTPS from VPC, TFC Agent VPC, and VPN clients"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr,
      var.tfc_agent_vpc_cidr,
      var.vpn_vpc_cidr,
      var.vpn_client_vpc_cidr
    ]
  }

  # -----------------------------------------------------------------------
  # INGRESS: Kafka (9092) — Broker protocol for produce/consume
  # -----------------------------------------------------------------------
  ingress {
    description = "Kafka from VPC, TFC Agent VPC, and VPN clients"
    from_port   = 9092
    to_port     = 9092
    protocol    = "tcp"
    cidr_blocks = [
      var.vpc_cidr,
      var.tfc_agent_vpc_cidr,
      var.vpn_vpc_cidr,
      var.vpn_client_vpc_cidr
    ]
  }

  # -----------------------------------------------------------------------
  # EGRESS: Intentionally empty
  # -----------------------------------------------------------------------
  #
  # By defining inline ingress rules WITHOUT defining any egress block,
  # Terraform takes full ownership of both directions and revokes the
  # default 0.0.0.0/0 egress rule that AWS auto-creates.
  #
  # This effectively denies all egress (Confluent-initiated) connections
  # from Confluent Cloud into the customer network, matching the
  # unidirectional posture of PrivateLink.
  #

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name        = "ccloud-pni-spoke-${local.network_id}"
    VPC         = aws_vpc.pni_spoke.id
    Environment = data.confluent_environment.pni_spoke.display_name
    ManagedBy   = "Terraform Cloud"
  }
}
