############################################################################
# EKS Cluster
############################################################################

module "eks_karpenter" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.30.1"

  cluster_name                    = "${var.project}-${var.name}-${var.environment}"
  cluster_version                 = var.eks_config.cluster_version
  cluster_endpoint_private_access = true

  ############## ENDPOINT ACCESS #########
  cluster_endpoint_public_access       = var.eks_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.eks_endpoint_public_access_cidrs
  ########################################

  ############## NETWORKING ##############
  vpc_id                   = var.vpc_id
  control_plane_subnet_ids = var.control_plane_subnet_ids
  subnet_ids               = var.nodes_subnet_ids
  ########################################

  ############## SECURITY ##############
  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group            = false
  create_node_security_group               = false
  enable_cluster_creator_admin_permissions = true

  cluster_additional_security_group_ids = var.control_plane_security_group_ids
  ########################################

  fargate_profiles = {
    karpenter = {
      name      = "karpenter"
      selectors = [{ namespace = "karpenter" }]
    }
  }

  access_entries = var.eks_access_entries

  tags = var.tags
}
