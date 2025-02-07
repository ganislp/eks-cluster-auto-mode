module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  cluster_endpoint_public_access           = true
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  create_kms_key                           = false
  cluster_encryption_config                = {}

  cluster_compute_config = {
    enabled = true
    node_pools = []
  }
  vpc_id                   = var.existing_vpc_id
  control_plane_subnet_ids = data.aws_subnets.private_subnets.ids
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



 resource "kubectl_manifest" "karpenter_node_class" {
yaml_body = templatefile("${path.module}/k8/node-class.yaml", {
    eks_cluster_name = module.eks.cluster_name
    eks_auto_node_policy = module.eks.node_iam_role_name
     node_class_name = local.node_class_name
  })
depends_on = [ module.eks.cluster_endpoint,module.eks.node_iam_role_name ]
 }

resource "kubectl_manifest" "karpenter_node_pool" {  
   for_each = toset(var.instance_architecture)
yaml_body = templatefile("${path.module}/k8/node-pool.yaml" ,{
    node_class_name = local.node_class_name
    node_pool_name = "${local.node_pool_name}-${each.value}"
    instance_cpu =   "${join("\", \"", var.instance_cpu)}"
    instance_category =  "${join("\", \"",  var.instance_category)}" 
    capacity_type =   "${join("\", \"",  var.capacity_type)}"  
    instance_architecture =    each.value
})
depends_on = [ kubectl_manifest.karpenter_node_class,   module.eks.cluster_endpoint ]
 }

#  resource "kubectl_manifest" "karpenter_graviton_node_pool" {  
# yaml_body = templatefile("${path.module}/k8/node-pool.yaml" ,{
#     node_class_name = local.node_class_name
#     node_pool_name = local.node_pool_name_graviton
#     instance_cpu =   "${join("\", \"", var.instance_cpu)}"
#     instance_category =  "${join("\", \"",  var.instance_category)}" 
#     capacity_type =   "${join("\", \"",  var.capacity_type)}"  
#     instance_architecture =    var.instance_architecture[1] 
# })
# depends_on = [ kubectl_manifest.karpenter_node_class,   module.eks.cluster_endpoint ]
#  }

