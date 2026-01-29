# Altinity ClickHouse Operator Helm Values
replicaCount: ${replicas}

%{ if metrics_enabled }
metrics:
  enabled: true
%{ endif }

# Operator configuration
operator:
  # Watch all namespaces by default
  watchNamespaces: []
