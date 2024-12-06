############################################################################
# Setup desired region
############################################################################
variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "AWS region"
}

############################################################################
# Project
############################################################################
variable "project" {
  type = string
}

############################################################################
# Cluster Name (between project and environment)
############################################################################
variable "name" {
  type = string
}

############################################################################
# Environment
############################################################################
variable "environment" {
  type = string
}


############################################################################
# VPC ID
############################################################################
variable "vpc_id" {
  type = string
}

############################################################################
# Control Plane Subnets IDs
############################################################################
variable "control_plane_subnet_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Nodes Subnets IDs
############################################################################
variable "nodes_subnet_ids" {
  type    = list(string)
  default = []
}

############################################################################
# PODs Subnets IDs
############################################################################
variable "pods_subnet_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Subnets External Presentation
############################################################################
variable "subnet_external_presentation_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Subnets Internal Presentation
############################################################################
variable "subnet_internal_presentation_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Control Plane Security Group IDs
############################################################################
variable "control_plane_security_group_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Karpenter Security Group IDs
############################################################################
variable "karpenter_security_group_ids" {
  type    = list(string)
  default = []
}

############################################################################
# Route 53 Zone ARNs to add to External DNS
############################################################################
variable "external_dns_hosted_zone_arns" {
  type    = list(string)
  default = []
}

############################################################################
# Availability Zones
############################################################################
variable "aws_availability_zones" {
  type        = list(string)
  default     = []
  description = "Availability Zones"
}

############################################################################
# EKS Endpoint Public Access
############################################################################
variable "eks_endpoint_public_access" {
  description = "Should the EKS management endpoint be public"
  type        = bool
  default     = true
}

############################################################################
# EKS Endpoint Public Access CIDRs
############################################################################
variable "eks_endpoint_public_access_cidrs" {
  description = "Public endpoint IP whitelisting"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

############################################################################
# EKS Cluster Configuration
############################################################################
variable "eks_config" {
  description = "EFS Storage Class specifications"
  type = object({

    cluster_version = string

    core_dns_addon_version   = string
    vpc_cni_addon_version    = string
    kube_proxy_addon_version = string

    lb_controller_namespace     = string
    lb_controller_chart_version = string

    ext_dns_controller_namespace = string
    ext_dns_chart_version        = string

    metrics_server_controller_namespace = string
    metrics_server_chart_version        = string

    karpenter = object({
      chart_version = string

      default_node_class = object({
        ami_id = string
      })

      default_node_pool = object({
        capacity_type = list(string)
        instance_cpu  = list(string)
      })

    })

  })

  default = {

    cluster_version = "1.31"

    core_dns_addon_version   = "v1.11.3-eksbuild.2"
    vpc_cni_addon_version    = "v1.19.0-eksbuild.1"
    kube_proxy_addon_version = "v1.31.2-eksbuild.3"

    lb_controller_namespace     = "aws-ingress"
    lb_controller_chart_version = "1.10.1"

    ext_dns_controller_namespace = "ext-dns"
    ext_dns_chart_version        = "1.15.0"

    metrics_server_controller_namespace = "metrics-server"
    metrics_server_chart_version        = "3.12.2"

    karpenter = {

      chart_version = "1.1.0"

      default_node_class = {
        ami_id = "ami-02ec061cab0494dc3" # bottlerocket-aws-k8s-1.31-x86_64
      }

      default_node_pool = {
        capacity_type = ["spot"]
        instance_cpu  = ["4"]
      }

    }

  }
}

############################################################################
# EKS Access Roles Configuration
############################################################################
variable "eks_access_entries" {
  description = "Map of roles to access EKS cluster"
  type        = any
  default     = null
}

############################################################################
# TAGs
############################################################################
variable "tags" {
  type    = map(string)
  default = {}
}