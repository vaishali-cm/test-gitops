# Flink Kubernetes Operator Helm Values

replicas: ${replicas}

image:
  repository: "${image_repository}"
%{ if image_tag != "" ~}
  tag: "${image_tag}"
%{ endif ~}

# Webhook configuration
webhook:
  create: ${webhook_enabled}
%{ if webhook_enabled ~}
  mutator:
    create: true
  validator:
    create: true
%{ endif ~}

# Watched namespaces (empty = all namespaces)
watchNamespaces:
%{ for ns in watch_namespaces ~}
  - "${ns}"
%{ endfor ~}

# Operator pod resources
operatorPod:
  resources:
    requests:
      cpu: "${resource_requests.cpu}"
      memory: "${resource_requests.memory}"
    limits:
      cpu: "${resource_limits.cpu}"
      memory: "${resource_limits.memory}"

# Metrics configuration
%{ if metrics_enabled ~}
metrics:
  port: 9999
%{ endif ~}

# Default configuration for Flink deployments
defaultConfiguration:
  create: true
  append: true
  flink-conf.yaml: |
    # Default Flink configuration
    kubernetes.operator.metrics.reporter.slf4j.factory.class: org.apache.flink.metrics.slf4j.Slf4jReporterFactory
    kubernetes.operator.metrics.reporter.slf4j.interval: 5 MINUTE
    kubernetes.operator.reconcile.interval: 15 s
    kubernetes.operator.observer.progress-check.interval: 5 s

# Logging configuration
operatorConfiguration:
  append: true
  log4j-operator.properties: |
    rootLogger.level = ${log_level}
    rootLogger.appenderRef.console.ref = ConsoleAppender
    appender.console.name = ConsoleAppender
    appender.console.type = Console
    appender.console.layout.type = PatternLayout
    appender.console.layout.pattern = %d{yyyy-MM-dd HH:mm:ss,SSS} %-5p %-60c %x - %m%n

# Job Manager defaults
jmTTLMinutes: 1440

# Pod template (optional)
podTemplate: {}

# Affinity, tolerations, nodeSelector
affinity: {}
tolerations: []
nodeSelector: {}
