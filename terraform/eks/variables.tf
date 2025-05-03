variable "region" {
  type        = string
  default     = "us-west-2"
}

variable "cluster_name" {
  type        = string
  default     = "icebergs-spark-cluster"
}

variable "vpc_id" {
  description = "VPC ID to deploy EKS into"
  type        = string
}

variable "subnet_ids" {
  description = "Subnets for EKS worker nodes"
  type        = list(string)
}

variable "eks_cluster_role_arn" {
  description = "IAM Role ARN for EKS cluster"
  type        = string
}

variable "eks_node_role_arn" {
  description = "IAM Role ARN for worker nodes"
  type        = string
}
