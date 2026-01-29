output "operator_release_name" {
  description = "Operator Helm release name"
  value       = helm_release.clickhouse_operator.name
}

output "release_name" {
  description = "ClickHouse installation name"
  value       = var.release_name
}

output "namespace" {
  description = "Deployment namespace"
  value       = var.namespace
}

output "service_name" {
  description = "ClickHouse service name"
  value       = "clickhouse-${var.release_name}"
}

output "http_port" {
  description = "HTTP interface port"
  value       = 8123
}

output "native_port" {
  description = "Native protocol port"
  value       = 9000
}
