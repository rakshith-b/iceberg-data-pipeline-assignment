terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.auth.token
}

data "aws_eks_cluster" "eks" {
  name = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "auth" {
  name = module.eks.cluster_name
}

module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  version         = "19.21.0"

  cluster_name    = var.cluster_name
  cluster_version = "1.27"
  vpc_id          = var.vpc_id
  subnet_ids      = var.subnet_ids

  cluster_endpoint_public_access = true

  # Set this to true to allow Terraform to manage aws-auth
  manage_aws_auth_configmap = true

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::760561616948:root"
      username = "root"
      groups   = ["system:masters"]
    }
  ]

  # Use IAM role created externally (from terraform/iam)
  iam_role_arn = var.eks_cluster_role_arn

  eks_managed_node_groups = {
    default = {
      name           = "default-node-group"
      desired_size   = 3
      max_size       = 4
      min_size       = 1
      instance_types = ["t3.medium"]

      iam_role_arn = var.eks_node_role_arn
    }
  }

  enable_irsa = true

  tags = {
    Environment = "dev"
    Terraform   = "true"
    Project     = "iceberg-pipeline"
  }
}
