module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  create_kms_key                           = false
  cluster_encryption_config                = {}
  bootstrap_self_managed_addons = false


  cluster_compute_config = {
    enabled = true
    node_pools = []
  }
  vpc_id                   = var.existing_vpc_id
  control_plane_subnet_ids = data.aws_subnets.private_subnets.ids
  cloudwatch_log_group_retention_in_days = 3
  cluster_enabled_log_types  = [ "audit", "api", "authenticator" ]

   tags = local.common_tags

  dataplane_wait_duration = "60s"
 depends_on       = [null_resource.check_workspace]
  
}

resource "aws_eks_access_entry" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
  
}

resource "aws_eks_access_policy_association" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn
  access_scope {
    type = "cluster"
  }
  }



