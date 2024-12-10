<!-- markdownlint-disable MD013 MD033  -->

# <div align= "center"></div>EKS Terraform Module<div align="center">

</div>
<!-- markdownlint-enable MD013 MD033 -->

Terraform module which creates Amazon EKS (Kubernetes) resources

## Usage

It should be used combined with vpc-eks module

```hcl
module "eks" {

  source = "git::https://GIT_DOMAIN/vfid-terraform-module-eks.git?ref=v1.0.1"
  
  project                  = var.project
  region                   = var.region
  name                     = "eks-1"
  environment              = local.environment
  
  vpc_id                   = var.vpc_main_cidr
  control_plane_subnet_ids = module.vpc.subnet_application_ids
  nodes_subnet_ids         = module.vpc.subnet_application_ids
  pods_subnet_ids          = module.vpc.subnet_intra_ids
  aws_availability_zones   = data.aws_availability_zones.available.names

  subnet_external_presentation_ids = module.vpc.subnet_external_presentation_ids
  subnet_internal_presentation_ids = module.vpc.subnet_internal_presentation_ids
  karpenter_security_group_ids = [module.vpc.security_group_id_karpenter_node]

  control_plane_security_group_ids = [module.vpc.security_group_id_k8_control_plane]
  external_dns_hosted_zone_arns = [aws_route53_zone.primary.arn]

  eks_config         = var.eks_config

  eks_access_entries = var.eks_access_entries

  tags = var.tags

}
```

## 🚀 Features

* Karpenter Autoscaler [Docs](https://karpenter.sh/docs/)
* AWS Load Balancer Controller [Docs](https://kubernetes-sigs.github.io/aws-load-balancer-controller/latest/guide/ingress/annotations/)
* External DNS Operator [Docs](https://kubernetes-sigs.github.io/external-dns/latest/)
* External Secrets Operator [Docs](https://github.com/external-secrets/external-secrets)
* Metrics Server [Docs](https://kubernetes-sigs.github.io/metrics-server/)
* Amazon distro for Opentelemetry (ADOT) with X-ray integration [Docs](https://aws-otel.github.io/docs/introduction)

## 📝 Roadmap

<!-- markdownlint-disable -->

- [ ] Verify with security if Bottlerocket OS can be used
- [ ] Add External Secrets Operator
- [ ] Add ADOT for tracing with X-Ray
- [ ] Add Managed Prometheus
- [ ] Add Managed Grafana

<!-- markdownlint-enable -->