# # VPC Output Values

# # VPC ID


# # VPC Private Subnets
# output "private_subnets" {
#   description = "List of IDs of private subnets"
#   value       = data.aws_subnets.private_subnets
# }

# # VPC Public Subnets
# output "public_subnets" {
#   description = "List of IDs of public subnets"
#   value       = data.aws_subnets.public_subnets
# }

# # VPC Public Subnets
# output "eks_auto_node_policy" {
#   description = "List of IDs of public subnets"
#   value       =  module.eks.node_iam_role_name
# }

# # VPC Public Subnets
# output "eks_cluster_name" {
#   description = "List of IDs of public subnets"
#   value       =  module.eks.cluster_name
# }





