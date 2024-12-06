################################################################################
# Namespace
################################################################################
resource "kubernetes_namespace" "metrics_server_controller" {
  metadata {

    labels = {
      app = "metrics-server"
    }

    name = var.eks_config.metrics_server_controller_namespace
  }
}


################################################################################
# Metrics Server
################################################################################
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = var.eks_config.metrics_server_controller_namespace
  repository = "https://kubernetes-sigs.github.io/metrics-server"
  chart      = "metrics-server"
  version    = var.eks_config.metrics_server_chart_version

  depends_on = [
    helm_release.karpenter, # Avoid creation errors before Karpenter is available
    kubernetes_namespace.metrics_server_controller
  ]

}