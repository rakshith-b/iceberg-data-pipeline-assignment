output "eks_cluster_role_arn" {
  value = aws_iam_role.eks_cluster_role.arn
}

output "eks_node_role_arn" {
  value = aws_iam_role.eks_node_role.arn
}

output "irsa_s3_role_arn" {
  value = aws_iam_role.irsa_s3_role.arn
}
