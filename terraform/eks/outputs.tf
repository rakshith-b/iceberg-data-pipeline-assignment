output "cluster_name" {
  value = module.eks.cluster_name
}

output "eks_oidc_provider_url" {
  value = module.eks.cluster_oidc_issuer_url
}

output "eks_oidc_provider_arn" {
  value = module.eks.oidc_provider_arn
}
