################################################################################
# Karpenter Default Node Class
################################################################################

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = templatefile("${path.module}/templates/karpenter_nodeclass.yaml.tpl", {
    PROJECT            = var.project,
    ENVIRONMENT        = var.environment,
    NODE_IAM_ROLE_NAME = module.karpenter.node_iam_role_name,
    CLUSTER_NAME       = module.eks_karpenter.cluster_name
    AMI_ID             = var.eks_config.karpenter.default_node_class.ami_id
  })

  depends_on = [
    helm_release.karpenter
  ]
}

################################################################################
# Karpenter Default Node Pool
################################################################################

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = templatefile("${path.module}/templates/karpenter_nodepool.yaml.tpl", {
    POOL_NAME     = "default",
    CAPACITY_TYPE = var.eks_config.karpenter.default_node_pool.capacity_type,
    INSTANCE_CPU  = var.eks_config.karpenter.default_node_pool.instance_cpu
  })

  depends_on = [
    kubectl_manifest.karpenter_node_class
  ]
}