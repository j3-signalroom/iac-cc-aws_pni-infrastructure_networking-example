resource "confluent_kafka_cluster" "sandbox_cluster" {
  display_name = "sandbox_cluster"
  availability = "HIGH"
  cloud        = local.cloud
  region       = var.aws_region
  enterprise   {}
  
  environment {
    id = confluent_environment.non_prod.id
  }

  depends_on = [ 
    module.sandbox_vpc_pni 
  ]
}

resource "confluent_kafka_cluster" "shared_cluster" {
  display_name = "shared_cluster"
  availability = "HIGH"
  cloud        = local.cloud
  region       = var.aws_region
  enterprise   {}
  
  environment {
    id = confluent_environment.non_prod.id
  }

  depends_on = [ 
    module.shared_vpc_pni 
  ]
}
