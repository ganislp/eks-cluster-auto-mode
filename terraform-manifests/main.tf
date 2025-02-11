module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_version = var.cluster_version
  cluster_name    = local.cluster_name

  cluster_endpoint_private_access          = true
  cluster_endpoint_public_access           = false
  enable_irsa                              = true
  enable_cluster_creator_admin_permissions = true
  bootstrap_self_managed_addons            = false
        create_kms_key                           = false
  cluster_encryption_config                = {}
  
  cluster_compute_config = {
    enabled    = true
    node_pools = []
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
 depends_on = [ module.eks.node_iam_role_arn]
}

resource "aws_eks_access_policy_association" "auto_mode" {
  cluster_name  = module.eks.cluster_name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSAutoNodePolicy"
  principal_arn = module.eks.node_iam_role_arn
  access_scope {
    type = "cluster"
  }
  depends_on = [ module.eks.node_iam_role_arn]
}



resource "tls_private_key" "my_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.my_key.public_key_openssh
}

resource "local_file" "private_key_pem" {
  filename = "${path.module}/${aws_key_pair.generated_key.key_name}.pem"
  content = tls_private_key.my_key.private_key_pem
  file_permission = "0400"
}

data "aws_ami" "amazon_linux_2" {
 most_recent = true
    owners = [ "amazon" ]

    filter {
      name = "name"
      values = [ "al2023-ami-2023*" ]
    }

    filter {
      name = "architecture"
      values = [ "x86_64" ]
    }

    filter {
      name = "root-device-type"
      values = [ "ebs" ]
    }

    filter {
      name = "virtualization-type"
      values = [ "hvm" ]
    }
}

# Security Group for Bastion Host
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.existing_vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}






# Bastion Host
resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.amazon_linux_2.id  
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnets.public_subnets.ids[0]
 security_groups = [aws_security_group.bastion_sg.id]
  key_name               = aws_key_pair.generated_key.key_name
  associate_public_ip_address = true
   user_data = file("userdata.sh")

   provisioner "file" {
    source      = "${path.module}/k8s_resources"  # Path to your local file
    destination = "/home/ec2-user/"  # Destination path on EC2

    connection {
      type        = "ssh"
      user        = "ec2-user"  # Change based on the AMI (ubuntu for Ubuntu instances)
      private_key = file("${path.module}/${aws_key_pair.generated_key.key_name}.pem")  # Path to your private key
      host        = self.public_ip
    }
   }

tags = {
    Name = "EKS-Access-Instance"
  }

}


resource "aws_security_group_rule" "allow_http" {
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = module.eks.cluster_security_group_id
  source_security_group_id = aws_security_group.bastion_sg.id  
  depends_on = [ aws_security_group.bastion_sg, module.eks.cluster_security_group_id]
}


