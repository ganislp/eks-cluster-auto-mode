module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = true
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  bootstrap_self_managed_addons            = false
  create_kms_key                           = false
  cluster_encryption_config                = {}


  cluster_compute_config = {
    enabled    = true
    node_pools = ["system"]
  }
  vpc_id                                 = var.existing_vpc_id
  control_plane_subnet_ids               = data.aws_subnets.private_subnets.ids
  # cloudwatch_log_group_retention_in_days = 3
  # cluster_enabled_log_types              = ["audit", "api", "authenticator"]

  tags = local.common_tags

  dataplane_wait_duration = "60s"
  depends_on              = [null_resource.check_workspace]

}

resource "aws_eks_access_entry" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  principal_arn = module.eks.node_iam_role_arn
  type          = "EC2"
  depends_on = [ module.eks.cluster_name]

}

resource "aws_eks_access_policy_association" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn
  access_scope {
    type = "cluster"
  }
  depends_on = [ module.eks.cluster_name]
}
data "kubectl_path_documents" "karpenter_node_class" {
 pattern = file("${path.module}/k8s_resources/node-class.yaml")

 vars = {
    eks_cluster_name     = module.eks.cluster_name
    eks_auto_node_policy = module.eks.node_iam_role_name
    node_class_name      = local.node_class_name
 }
  # yaml_body = templatefile("${path.module}/k8s_resources/node-class.yaml", {
  #   eks_cluster_name     = module.eks.cluster_name
  #   eks_auto_node_policy = module.eks.node_iam_role_name
  #   node_class_name      = local.node_class_name
  # })
  depends_on = [module.eks.cluster_endpoint, module.eks.node_iam_role_name]
}

# Create a VPC Endpoint for EKS API (example for private API)
resource "aws_vpc_endpoint" "eks" {
  vpc_id       = var.existing_vpc_id
  service_name = "com.amazonaws.${var.aws_region}.eks"

  vpc_endpoint_type = "Interface"

  security_group_ids = [aws_security_group.eks_endpoint.id]
  subnet_ids         = data.aws_subnets.private_subnets.ids

  private_dns_enabled = true
}

# Security Group for VPC Endpoint
resource "aws_security_group" "eks_endpoint" {
  name   = "eks-vpc-endpoint-sg"
  vpc_id = var.existing_vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Update with your VPC CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# resource "kubectl_manifest" "karpenter_node_pool" {
#   for_each = toset(var.instance_architecture)
#   yaml_body = templatefile("${path.module}/k8s_resources/node-pool.yaml", {
#     node_class_name       = local.node_class_name
#     node_pool_name        = "${local.node_pool_name}-${each.value}"
#     instance_cpu          = "${join("\", \"", var.instance_cpu)}"
#     instance_category     = "${join("\", \"", var.instance_category)}"
#     capacity_type         = "${join("\", \"", var.capacity_type)}"
#     instance_size         = "${join("\", \"", var.instance_size)}"
#     instance_architecture = each.value
#     taints_key            = "${local.node_pool_name}-${each.value}"
#   })
#   depends_on = [kubectl_manifest.karpenter_node_class, module.eks.cluster_endpoint]
# }


