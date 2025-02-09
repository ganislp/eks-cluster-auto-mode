data "aws_eks_cluster" "cluster" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

data "aws_eks_cluster_auth" "this" {
  name       = module.eks.cluster_name
  depends_on = [module.eks.cluster_name]
}

# Datasource: EKS Cluster Authentication
# data "aws_eks_cluster_auth" "cluster" {
#   name =  var.project_name
# }



provider "kubectl" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}

provider "aws" {
  region  = var.aws_region
  profile = "default"

}

provider "null" {}
