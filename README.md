# Infrastructure GitOps Repository

This repository contains Terraform configurations for deploying **Apache Flink** and **ClickHouse** on existing Kubernetes clusters using a GitOps approach.

## Repository Structure

```
.
├── modules/                    # Reusable Terraform modules
│   ├── flink/                  # Flink Kubernetes Operator module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   ├── versions.tf
│   │   └── templates/
│   │       ├── values.yaml.tpl
│   │       └── flink-conf.yaml.tpl
│   └── clickhouse/             # ClickHouse Operator module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       ├── versions.tf
│       └── templates/
│           ├── operator-values.yaml.tpl
│           └── clickhouse-cluster.yaml.tpl
├── environments/               # Environment-specific configurations
│   ├── dev/                    # Development environment
│   ├── staging/                # Staging environment
│   └── prod/                   # Production environment
├── .gitignore
└── README.md
```

## Prerequisites

- Terraform >= 1.5.0
- Existing Kubernetes cluster
- `kubectl` configured with cluster access
- Helm 3.x

## Quick Start

### 1. Clone the repository

```bash
git clone <repository-url>
cd test-gitops
```

### 2. Configure your environment

```bash
cd environments/dev  # or staging/prod

# Copy the example tfvars file
cp terraform.tfvars.example terraform.tfvars

# Edit with your configuration
vim terraform.tfvars
```

### 3. Initialize and apply

```bash
# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Apply the configuration
terraform apply
```

## Modules

### Flink Module

Deploys the Apache Flink Kubernetes Operator and optionally creates default configurations.

**Features:**
- Deploys Flink Kubernetes Operator via Helm
- Configurable resource limits and requests
- Optional default Flink configuration ConfigMap
- Support for RocksDB state backend
- Checkpoint configuration

**Usage:**

```hcl
module "flink" {
  source = "../../modules/flink"

  namespace        = "flink"
  release_name     = "flink-operator"
  operator_version = "1.8.0"
  
  resource_requests = {
    cpu    = "100m"
    memory = "256Mi"
  }
}
```

### ClickHouse Module

Deploys the Altinity ClickHouse Operator and optionally creates a ClickHouse cluster.

**Features:**
- Deploys Altinity ClickHouse Operator via Helm
- Creates ClickHouse cluster via Custom Resource
- Configurable sharding and replication
- ZooKeeper integration for replication
- Persistent storage configuration

**Usage:**

```hcl
module "clickhouse" {
  source = "../../modules/clickhouse"

  namespace      = "clickhouse"
  cluster_name   = "my-cluster"
  cluster_replicas = 3
  cluster_shards   = 2
  
  storage_size = "100Gi"
}
```

## Environment Configurations

### Development (`environments/dev`)
- Single replica deployments
- Minimal resource allocation
- No ZooKeeper (single node ClickHouse)
- Suitable for local development and testing

### Staging (`environments/staging`)
- 2 replicas for HA testing
- Moderate resource allocation
- ZooKeeper enabled for replication testing
- Mirrors production topology at smaller scale

### Production (`environments/prod`)
- High availability configuration
- Full resource allocation
- ZooKeeper enabled
- Multi-shard ClickHouse cluster
- Optimized checkpoint and restart strategies

## Configuration

### Kubernetes Authentication

Configure access to your Kubernetes cluster:

```hcl
# In terraform.tfvars
kubeconfig_path    = "~/.kube/config"
kubeconfig_context = "my-cluster-context"
```

### Remote State Backend

Uncomment and configure the backend block in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "your-terraform-state-bucket"
    key            = "env/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}
```

## GitOps Workflow

### Recommended CI/CD Pipeline

1. **Pull Request**: `terraform plan` runs automatically
2. **Review**: Team reviews the plan output
3. **Merge**: After approval, merge to main
4. **Apply**: CI/CD applies changes to the cluster

### Branch Strategy

- `main` - Production deployments
- `staging` - Staging deployments
- `feature/*` - Feature branches for development

## Accessing Services

### Flink

After deployment, access the Flink dashboard:

```bash
kubectl port-forward -n flink-<env> svc/flink-operator-webhook 8443:443
```

### ClickHouse

Connect to ClickHouse:

```bash
# Port forward the native protocol
kubectl port-forward -n clickhouse-<env> svc/clickhouse-<cluster-name> 9000:9000

# Connect with clickhouse-client
clickhouse-client --host localhost --port 9000
```

## Troubleshooting

### Common Issues

1. **Operator not starting**: Check if CRDs are installed
   ```bash
   kubectl get crd | grep flink
   kubectl get crd | grep clickhouse
   ```

2. **Pods pending**: Check node resources and storage class availability
   ```bash
   kubectl describe pod <pod-name> -n <namespace>
   ```

3. **Helm release stuck**: Force cleanup if needed
   ```bash
   helm uninstall <release-name> -n <namespace>
   ```

## Contributing

1. Create a feature branch
2. Make changes
3. Run `terraform fmt` and `terraform validate`
4. Create a pull request
5. Wait for plan output and review

## License

[Your License Here]
