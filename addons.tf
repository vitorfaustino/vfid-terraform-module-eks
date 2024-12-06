################################################################################
# Core DNS Addon
################################################################################
resource "aws_eks_addon" "core_dns" {
  addon_name                  = "coredns"
  cluster_name                = module.eks_karpenter.cluster_name
  addon_version               = var.eks_config.core_dns_addon_version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      "eks_addon" = "coredns"
    }
  )

  depends_on = [
    module.eks_karpenter.fargate_profiles
  ]
}

################################################################################
# CNI Addon
################################################################################
resource "aws_eks_addon" "vpc_cni" {
  addon_name                  = "vpc-cni"
  cluster_name                = module.eks_karpenter.cluster_name
  addon_version               = var.eks_config.vpc_cni_addon_version
  resolve_conflicts_on_create = "OVERWRITE"

  configuration_values = jsonencode({
    env = {
      AWS_VPC_K8S_CNI_CUSTOM_NETWORK_CFG = "true"
      ENABLE_PREFIX_DELEGATION           = "true"
      WARM_PREFIX_TARGET                 = "1"
      ENI_CONFIG_LABEL_DEF               = "topology.kubernetes.io/zone"
    }
  })

  tags = merge(
    var.tags,
    {
      "eks_addon" = "vpc_cni"
    }
  )
}

################################################################################
# Kube Proxy Addon
################################################################################
resource "aws_eks_addon" "kube_proxy" {
  addon_name                  = "kube-proxy"
  cluster_name                = module.eks_karpenter.cluster_name
  addon_version               = var.eks_config.kube_proxy_addon_version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = merge(
    var.tags,
    {
      "eks_addon" = "kube-proxy"
    }
  )
}