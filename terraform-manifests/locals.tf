# Define Local Values in Terraform
locals {
  name = "${var.business_divsion}-${var.environment}"
  prefix_env = "${var.business_divsion}-${var.environment}-${var.cluster_prefix}"
  cluster_name    = "${local.prefix_env}-cluster"
  private_subnets-prefix   = "${local.cluster_name}-private-subnet"
  public_subnets-prefix   = "${local.cluster_name}-public-subnet"
  node_class_name    = "${local.prefix_env}-nodeclass"
   node_pool_name    = "${local.prefix_env}-nodepool"
  node_pool_name_graviton    = "${local.prefix_env}-gravtion-nodepool"
  common_tags = {
    owners =  var.business_divsion
    environment = var.environment
  }

} 