################################################################################
# Controller & Node IAM roles, SQS Queue, Eventbridge Rules
################################################################################

module "karpenter" {
  source  = "terraform-aws-modules/eks/aws//modules/karpenter"
  version = "20.30.1"

  cluster_name          = module.eks_karpenter.cluster_name
  enable_v1_permissions = true
  namespace             = "karpenter"

  # Name needs to match role name passed to the EC2NodeClass
  node_iam_role_use_name_prefix = false
  node_iam_role_name            = "${var.project}-role-karpenter-${var.environment}"

  # EKS Fargate does not support pod identity
  create_pod_identity_association = false
  enable_irsa                     = true
  irsa_oidc_provider_arn          = module.eks_karpenter.oidc_provider_arn

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags

  depends_on = [
    module.eks_karpenter.fargate_profiles
  ]
}

################################################################################
# Helm charts
################################################################################
resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = "karpenter"
  create_namespace = true
  repository       = "oci://public.ecr.aws/karpenter"
  //repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  //repository_password = data.aws_ecrpublic_authorization_token.token.password
  chart   = "karpenter"
  version = var.eks_config.karpenter.chart_version
  wait    = false

  values = [
    <<-EOT
    dnsPolicy: Default
    logLevel: debug
    settings:
      clusterName: ${module.eks_karpenter.cluster_name}
      clusterEndpoint: ${module.eks_karpenter.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    webhook:
      enabled: false
    EOT
  ]

  lifecycle {
    ignore_changes = [
      repository_password
    ]
  }

  depends_on = [
    module.karpenter
  ]
}