locals {
  deployment_id = lower("${var.deployment_name}-${random_string.suffix.result}")
}

resource "random_string" "suffix" {
  length  = 8
  special = false
}

module "infra_aws" {
  source          = "./modules/infra_aws"
  deployment_id   = local.deployment_id
  owner           = var.owner
  vpc_cidr        = var.aws_vpc_cidr
  public_subnets  = var.aws_public_subnets
  private_subnets = var.aws_private_subnets
  instance_type   = var.aws_instance_type
}
