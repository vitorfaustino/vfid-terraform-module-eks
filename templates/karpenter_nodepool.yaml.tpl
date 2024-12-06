apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: ${POOL_NAME}
  annotations:
    kubernetes.io/description: "General purpose NodePool for generic workloads"
spec:
  template:
    spec:
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      requirements:
        - key: karpenter.sh/capacity-type
          operator: In
          values: ${jsonencode(CAPACITY_TYPE)}
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-size
          operator: NotIn
          values: ["nano","micro","small","medium"]
        - key: "karpenter.k8s.aws/instance-cpu"
          operator: In
          values: ${jsonencode(INSTANCE_CPU)}
        - key: "kubernetes.io/arch"
          operator: In
          values: ["amd64"]
        - key: "karpenter.k8s.aws/instance-generation"
          operator: Gt
          values: ["5"]
limits:
  cpu: 1000
disruption:
  consolidationPolicy: WhenEmptyOrUnderutilized
  consolidateAfter: 30s
  # Priority given to the NodePool when the scheduler considers which NodePool
  # to select. Higher weights indicate higher priority when comparing NodePools.
  # Specifying no weight is equivalent to specifying a weight of 0.
weight: 10