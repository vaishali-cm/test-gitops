apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: ${name}
  namespace: ${namespace}
  labels:
%{ for key, value in labels ~}
    ${key}: "${value}"
%{ endfor ~}
spec:
  configuration:
    clusters:
      - name: ${name}
        layout:
          shardsCount: ${shards}
          replicasCount: ${replicas}
%{ if zookeeper_enabled }
    zookeeper:
      nodes:
        - host: ${zookeeper_service}.${zookeeper_namespace}
          port: 2181
%{ endif }
    settings:
      max_concurrent_queries: 100
      max_connections: 4096
%{ for key, value in additional_settings ~}
      ${key}: ${value}
%{ endfor ~}
  defaults:
    templates:
      podTemplate: pod-template
      dataVolumeClaimTemplate: data-volume-template
  templates:
    podTemplates:
      - name: pod-template
        spec:
          containers:
            - name: clickhouse
              image: clickhouse/clickhouse-server:${clickhouse_version}
              resources:
                requests:
                  cpu: "${cpu_requests}"
                  memory: "${memory_requests}"
                limits:
                  cpu: "${cpu_limits}"
                  memory: "${memory_limits}"
    volumeClaimTemplates:
      - name: data-volume-template
        spec:
          accessModes:
            - ReadWriteOnce
          storageClassName: ${storage_class}
          resources:
            requests:
              storage: ${storage_size}
