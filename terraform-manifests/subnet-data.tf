

data "aws_subnets" "private_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  tags = {
    "karpenter.sh/discovery" = local.cluster_name
     Name =  local.private_subnets-prefix
  }
}

data "aws_subnets" "public_subnets" {
  filter {
    name   = "vpc-id"
    values = [var.existing_vpc_id]
  }

  tags = {
     "karpenter.sh/discovery" = local.cluster_name
      Name =  local.public_subnets-prefix
  }
}