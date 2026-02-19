data "confluent_environment" "pni_spoke" {
  id = var.confluent_environment_id
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_availability_zone" "selected" {
  count = var.subnet_count
  name  = data.aws_availability_zones.available.names[count.index]
}

locals {
  available_zones    = data.aws_availability_zones.available.names
  available_zone_ids = [for az in data.aws_availability_zone.selected : az.zone_id]
  network_id         = "${data.confluent_environment.pni_spoke.display_name}-${var.vpc_name}"
}
