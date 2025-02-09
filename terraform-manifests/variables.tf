# Input Variables
# AWS Region
variable "aws_region" {
  description = "Region in which AWS Resources to be created"
  type        = string
  default     = "us-east-1"
}
# Environment Variable
variable "environment" {
  description = "Environment Variable used as a prefix"
  type        = string
  default     = "dev"
}
# Business Division
variable "business_divsion" {
  description = "Business Division in the large organization this Infrastructure belongs"
  type        = string
  default     = "health"
}

variable "cluster_version" {
  description = "EKS Cluster Version"
  type        = string
  default     = "1.32"
}

variable "cluster_prefix" {
  description = "cluster prefix"
  type        = string
  default     = "eks"
}

variable "instance_cpu" {
  description = "Instance cpus  used to node pools"
  type        = list(string)
}

variable "instance_category" {
  description = "Instance category  used to node pools"
  type        = list(string)
}

variable "instance_architecture" {
  description = "Instance architecture  used to node pools"
  type        = list(string)
}

variable "capacity_type" {
  description = "Instance apacity type  used to node pools"
  type        = list(string)
}

variable "existing_vpc_id" {
  description = "VPC id"
  type        = string
}

variable "instance_size" {
  description = "Instance size type  used to node pools"
  type        = list(string)
}



