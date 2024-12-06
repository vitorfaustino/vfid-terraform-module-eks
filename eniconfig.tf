################################################################################
# EKS ENI Config
# https://github.com/aws-ia/terraform-aws-eks-blueprints/issues/1675
################################################################################

resource "kubectl_manifest" "eni_config" {
  count = length(var.pods_subnet_ids)

  yaml_body = yamlencode({
    apiVersion = "crd.k8s.amazonaws.com/v1alpha1"
    kind       = "ENIConfig"
    metadata = {
      name = var.aws_availability_zones[count.index]
    }
    spec = {
      subnet = var.pods_subnet_ids[count.index]
    }
  })

  depends_on = [
    module.eks_karpenter
  ]
}