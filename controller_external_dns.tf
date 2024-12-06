################################################################################
# Namespace
################################################################################
resource "kubernetes_namespace" "ext_dns_controller" {
  metadata {

    labels = {
      app = "external-dns"
    }

    name = var.eks_config.ext_dns_controller_namespace
  }
}

################################################################################
# IRSA for External DNS
################################################################################
module "external_dns_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.48.0"

  role_name                     = "${var.project}-role-eks-external-dns-controller-${var.environment}"
  policy_name_prefix            = "${var.project}-policy-eks-external-dns-${var.environment}-"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = var.external_dns_hosted_zone_arns

  oidc_providers = {
    eks = {
      provider_arn               = module.eks_karpenter.oidc_provider_arn
      namespace_service_accounts = ["${var.eks_config.ext_dns_controller_namespace}:external-dns"]
    }
  }

  tags = var.tags
}


resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = var.eks_config.ext_dns_controller_namespace
  version    = var.eks_config.ext_dns_chart_version

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = module.external_dns_controller_irsa_role.iam_role_arn
  }

  depends_on = [
    helm_release.karpenter, # Avoid creation errors before Karpenter is available
    kubernetes_namespace.ext_dns_controller
  ]

}