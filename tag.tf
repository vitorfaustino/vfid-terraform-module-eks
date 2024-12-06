resource "aws_ec2_tag" "sb_karpenter_application" {
  count       = length(var.nodes_subnet_ids)
  resource_id = var.nodes_subnet_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = module.eks_karpenter.cluster_name
}

resource "aws_ec2_tag" "sb_karpenter_external_presentation" {
  count       = length(var.subnet_external_presentation_ids)
  resource_id = var.subnet_external_presentation_ids[count.index]
  key         = "kubernetes.io/role/elb"
  value       = "1"
}

resource "aws_ec2_tag" "sb_karpenter_internal_presentation" {
  count       = length(var.subnet_internal_presentation_ids)
  resource_id = var.subnet_internal_presentation_ids[count.index]
  key         = "kubernetes.io/role/internal-elb"
  value       = "1"
}

resource "aws_ec2_tag" "sgs_karpenter" {
  count       = length(var.karpenter_security_group_ids)
  resource_id = var.karpenter_security_group_ids[count.index]
  key         = "karpenter.sh/discovery"
  value       = module.eks_karpenter.cluster_name
}