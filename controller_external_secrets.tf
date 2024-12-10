################################################################################
# Namespace
################################################################################
resource "kubernetes_namespace" "ext_secrets_controller" {
  metadata {

    labels = {
      app = "external-secrets"
    }

    name = var.eks_config.ext_secrets_controller_namespace
  }
}

################################################################################
# IRSA for External Secrets
################################################################################
module "external_secrets_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.48.0"

  role_name                     = "${var.project}-role-eks-external-secrets-controller-${var.environment}"
  policy_name_prefix            = "${var.project}-policy-eks-external-secrets-${var.environment}-"
  attach_external_secrets_policy    = true

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_karpenter.oidc_provider_arn
      namespace_service_accounts = ["${var.eks_config.ext_secrets_controller_namespace}:external-secrets"]
    }
  }

  tags = var.tags
}

################################################################################
# Helm chart for External Secrets
################################################################################
resource "helm_release" "external_secrets" {
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = var.eks_config.ext_secrets_controller_namespace
  version    = var.eks_config.ext_secrets_chart_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = module.external_secrets_controller_irsa_role.iam_role_arn
  }

  depends_on = [
    helm_release.karpenter, # Avoid creation errors before Karpenter is available
    kubernetes_namespace.ext_secrets_controller
  ]

}