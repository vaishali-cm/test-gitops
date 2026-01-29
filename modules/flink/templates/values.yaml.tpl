# Flink Kubernetes Operator Helm Values
replicas: ${replicas}

image:
  tag: "${image_tag}"

webhook:
  create: ${webhook_enabled}

metrics:
  port: 9999

operatorPod:
  resources:
    requests:
      cpu: "${resource_requests.cpu}"
      memory: "${resource_requests.memory}"
    limits:
      cpu: "${resource_limits.cpu}"
      memory: "${resource_limits.memory}"

%{ if metrics_enabled }
operatorMetrics:
  enabled: true
%{ endif }
