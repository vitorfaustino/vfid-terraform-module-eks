################################################################################
# LB Controller namespace
################################################################################
resource "kubernetes_namespace" "lb_controller" {
  metadata {

    labels = {
      app = "load_balancer"
    }

    name = var.eks_config.lb_controller_namespace
  }
}

################################################################################
# LB Controller IRSA
################################################################################
module "load_balancer_controller_irsa_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.48.0"

  role_name                              = "${var.project}-role-eks-lb-controller-${var.environment}"
  policy_name_prefix                     = "${var.project}-policy-eks-lb-controller-${var.environment}-"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_karpenter.oidc_provider_arn
      namespace_service_accounts = ["${var.eks_config.lb_controller_namespace}:aws-load-balancer-controller"]
    }
  }

  tags = var.tags
}

################################################################################
# LB Controller Helm chart
################################################################################
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = var.eks_config.lb_controller_namespace
  version    = var.eks_config.lb_controller_chart_version

  set {
    name  = "region"
    value = var.region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "image.repository"
    value = "602401143452.dkr.ecr.${var.region}.amazonaws.com/amazon/aws-load-balancer-controller"
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com\\/role-arn"
    value = module.load_balancer_controller_irsa_role.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks_karpenter.cluster_name
  }
  set {
    name  = "logLevel"
    value = "info" #debug
  }
  set {
    name  = "enableServiceMutatorWebhook"
    value = "false"
  }

  depends_on = [
    helm_release.karpenter, # Avoid creation errors before Karpenter is available
    kubernetes_namespace.lb_controller
  ]
}