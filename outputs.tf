output "cluster_name" {
  value = module.eks_karpenter.cluster_name
}

output "oidc_provider_arn" {
  value = module.eks_karpenter.oidc_provider_arn
}

output "cluster_endpoint" {
  value = module.eks_karpenter.cluster_endpoint
}

output "cluster_certificate_authority_data" {
  value = module.eks_karpenter.cluster_certificate_authority_data
}