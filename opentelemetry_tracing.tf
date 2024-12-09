
################################################################################
# IRSA for Opentelemetry
################################################################################
module "otel_controller_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.48.0"

  role_name                              = "${var.project}-role-eks-otel-controller-${var.environment}"
  role_policy_arns = {  
    xRay   = "arn:aws:iam::aws:policy/AWSXrayWriteOnlyAccess",
    cwLogs = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }

  oidc_providers = {
    ex = {
      provider_arn               = module.eks_karpenter.oidc_provider_arn
      namespace_service_accounts = ["adot:sa-adot"]
    }
  }

  tags = var.tags
}

################################################################################
# ADOT Namespace
################################################################################
resource "kubernetes_namespace" "aws_otel" {
  metadata {

    labels = {
      app = "adot"
    }

    name = "adot"
  }

  depends_on = [
    helm_release.karpenter
  ]
}

################################################################################
# ADOT Configmap
################################################################################
resource "kubectl_manifest" "adot_tracing_configmap" {
  yaml_body = <<-YAML

apiVersion: v1
kind: ConfigMap
metadata:
  name: adot-config
  namespace: "${kubernetes_namespace.aws_otel.id}"
data:
  adot-config.yaml: |
    exporters:
      awsxray:
        region: "${var.region}"
    receivers:
      otlp:
        protocols:
          grpc:
            endpoint: 0.0.0.0:4317
          http:
            endpoint: 0.0.0.0:4318
    service:
      pipelines:
        traces:
          exporters:
            - awsxray
          receivers:
            - otlp

  YAML
}


resource "kubectl_manifest" "adot_tracing_serviceaccount" {
  yaml_body = <<-YAML

apiVersion: v1
kind: ServiceAccount
metadata:
  name: sa-adot
  namespace: "${kubernetes_namespace.aws_otel.id}"
  annotations:
    eks.amazonaws.com/role-arn: "${module.otel_controller_irsa_role.iam_role_arn}"

  YAML
}

resource "kubectl_manifest" "adot_tracing_service" {
  yaml_body = <<-YAML

apiVersion: v1
kind: Service
metadata:
  name: adot-collector-service
  namespace: "${kubernetes_namespace.aws_otel.id}"
spec:
  selector:
    app: adot-collector
  ports:
    - protocol: TCP
      port: 4317
      targetPort: 4317

  YAML
}

resource "kubectl_manifest" "adot_tracing_deployment" {
  yaml_body = <<-YAML

apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: adot-collector
  name: adot-collector
  namespace: "${kubernetes_namespace.aws_otel.id}"
spec:
  replicas: 1
  selector:
    matchLabels:
      app: adot-collector
  template:
    metadata:
      labels:
        app: adot-collector
    spec:
      serviceAccountName: sa-adot
      containers:
        - args:
            - '--config=/etc/adot-config.yaml'
          image: public.ecr.aws/aws-observability/aws-otel-collector:v0.41.1
          name: adot-collector
          volumeMounts:
            - mountPath: /etc/adot-config.yaml
              name: config-volume
              subPath: adot-config.yaml
          resources:
            limits:
              cpu: "2"
              memory: 400Mi
            requests:
              cpu: 200m
              memory: 400Mi
      volumes:
        - configMap:
            name: adot-config
          name: config-volume

  YAML
}