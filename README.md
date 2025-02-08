# eks-cluster-auto-mode
eks cluster auto mode with customized  node class and node pools with amd64 and arm64

This repo provides the Terraform configuration to deploy a demo app running on an AWS EKS Cluster with Auto Mode enabled, using best practices.


To learn more about AWS EKS Auto Mode, see the AWS Documentation. EKS Auto Mode automates:

Compute: It creates new nodes when pods can't fit onto existing ones, and identifies low utilization nodes for deletion.
Networking: It configures AWS Load Balancers for Kubernetes Service and Ingress resources, to expose cluster apps to the internet.
Storage: It creates EBS Volumes to back Kubernetes storage resources.
In these Terraform files, comments describe how AWS EKS Auto Mode simplifies and changes deployment. You can search for "EKS Auto Mode" to find these comments.
