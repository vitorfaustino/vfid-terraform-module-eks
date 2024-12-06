apiVersion: karpenter.k8s.aws/v1 
kind: EC2NodeClass
metadata:
  name: default
spec:
  metadataOptions:
    httpEndpoint: enabled
    httpProtocolIPv6: disabled
    httpPutResponseHopLimit: 2 # https://github.com/open-telemetry/opentelemetry-collector-contrib/issues/31511
    httpTokens: required
  amiFamily: Bottlerocket
  role: ${NODE_IAM_ROLE_NAME}
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${CLUSTER_NAME}
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: ${CLUSTER_NAME}
  # Optional, propagates tags to underlying EC2 resources
  tags:
    karpenter.sh/discovery: ${CLUSTER_NAME}
    Name: ${PROJECT}-karpenter-nodepool-1-${ENVIRONMENT}
  amiSelectorTerms:
    - id: ${AMI_ID}
  blockDeviceMappings:
    # Root device
    - deviceName: /dev/xvda
      ebs:
        volumeSize: 4Gi
        volumeType: gp3
        encrypted: true
        deleteOnTermination: true
    # Data device: Container resources such as images and logs
    - deviceName: /dev/xvdb
      ebs:
        volumeSize: 20Gi
        volumeType: gp3
        encrypted: true
        deleteOnTermination: true