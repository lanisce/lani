# Lani Helm Chart

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/lani)](https://artifacthub.io/packages/search?repo=lani)
[![Release Charts](https://github.com/your-org/lani/actions/workflows/helm-release.yml/badge.svg)](https://github.com/your-org/lani/actions/workflows/helm-release.yml)

A comprehensive project management and collaboration platform Helm chart for Kubernetes.

## Features

- **Complete Platform**: Project management, task tracking, financial management, e-commerce, and team collaboration
- **External Integrations**: OpenProject, Maybe Finance, Nextcloud, Mapbox, Medusa, and Stripe
- **Flexible Deployment**: Support for internal or external PostgreSQL and Redis
- **Production Ready**: Autoscaling, monitoring, security policies, and backup configurations
- **Cloud Native**: Built for Kubernetes with best practices

## Quick Start

### Add Helm Repository

```bash
helm repo add lani https://your-org.github.io/lani/
helm repo update
```

### Install Chart

```bash
# Install with default values (internal PostgreSQL and Redis)
helm install lani lani/lani

# Install with custom values
helm install lani lani/lani -f values.yaml

# Install in specific namespace
helm install lani lani/lani --namespace lani-production --create-namespace
```

## Configuration

### Basic Configuration

```yaml
# values.yaml
postgresql:
  type: internal  # or external
  internal:
    auth:
      username: lani
      database: lani_production

redis:
  type: internal  # or external

ingress:
  enabled: true
  hosts:
    - host: lani.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
```

### External Services Configuration

```yaml
# Use external PostgreSQL
postgresql:
  type: external
  external:
    host: your-postgres.amazonaws.com
    port: 5432
    username: lani
    password: your-password
    database: lani_production
    sslMode: require

# Use external Redis
redis:
  type: external
  external:
    host: your-redis.cache.amazonaws.com
    port: 6379
    password: your-redis-password
    database: 0
```

### Secrets Management

```yaml
# Internal secrets (not recommended for production)
secrets:
  create: true
  external: false
  data:
    SECRET_KEY_BASE: "your-secret-key"
    STRIPE_SECRET_KEY: "sk_live_..."

# External secrets (recommended for production)
secrets:
  create: true
  external: true
  externalSecretStore: "aws-secrets-manager"
```

## Configuration Options

### Application Settings

| Parameter | Description | Default |
|-----------|-------------|---------|
| `image.registry` | Container image registry | `ghcr.io` |
| `image.repository` | Container image repository | `your-org/lani` |
| `image.tag` | Container image tag | `latest` |
| `replicaCount` | Number of web replicas | `3` |

### Database Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `postgresql.type` | Database type (`internal` or `external`) | `internal` |
| `postgresql.internal.auth.username` | PostgreSQL username | `lani` |
| `postgresql.internal.auth.database` | PostgreSQL database name | `lani_production` |
| `postgresql.external.host` | External PostgreSQL host | `""` |
| `postgresql.external.port` | External PostgreSQL port | `5432` |

### Cache Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `redis.type` | Redis type (`internal` or `external`) | `internal` |
| `redis.internal.auth.enabled` | Enable Redis authentication | `true` |
| `redis.external.host` | External Redis host | `""` |
| `redis.external.port` | External Redis port | `6379` |

### Scaling Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `autoscaling.web.enabled` | Enable web autoscaling | `true` |
| `autoscaling.web.minReplicas` | Minimum web replicas | `3` |
| `autoscaling.web.maxReplicas` | Maximum web replicas | `10` |
| `autoscaling.sidekiq.enabled` | Enable Sidekiq autoscaling | `true` |
| `autoscaling.sidekiq.minReplicas` | Minimum Sidekiq replicas | `2` |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `networkPolicy.enabled` | Enable network policies | `true` |
| `podSecurityPolicy.enabled` | Enable pod security policies | `true` |
| `securityContext.runAsNonRoot` | Run as non-root user | `true` |
| `securityContext.runAsUser` | User ID to run as | `1001` |

## External Integrations

Configure external service integrations through environment variables:

```yaml
env:
  # Stripe Payments
  ENABLE_STRIPE_PAYMENTS: "true"
  
  # Mapbox Integration
  ENABLE_MAPBOX_INTEGRATION: "true"
  
  # OpenProject Integration
  ENABLE_OPENPROJECT_INTEGRATION: "true"
  OPENPROJECT_URL: "https://your-openproject.com"
  
  # Maybe Finance Integration
  ENABLE_MAYBE_INTEGRATION: "true"
  MAYBE_API_URL: "https://api.maybe.finance"
  
  # Nextcloud Integration
  ENABLE_NEXTCLOUD_INTEGRATION: "true"
  NEXTCLOUD_URL: "https://your-nextcloud.com"
  
  # Medusa E-commerce Integration
  ENABLE_MEDUSA_INTEGRATION: "true"
  MEDUSA_API_URL: "https://your-medusa.com"

secrets:
  data:
    STRIPE_SECRET_KEY: "sk_live_..."
    MAPBOX_ACCESS_TOKEN: "pk.eyJ1..."
    OPENPROJECT_API_KEY: "your-api-key"
    MAYBE_API_KEY: "your-api-key"
    NEXTCLOUD_USERNAME: "your-username"
    NEXTCLOUD_PASSWORD: "your-password"
    MEDUSA_API_KEY: "your-api-key"
```

## Production Deployment

### Prerequisites

1. Kubernetes cluster (1.19+)
2. Helm 3.8+
3. Ingress controller (nginx recommended)
4. Cert-manager for SSL certificates
5. External database and Redis (recommended for production)

### Production Values Example

```yaml
# production-values.yaml
replicaCount: 5

postgresql:
  type: external
  external:
    host: your-rds-endpoint.amazonaws.com
    username: lani
    database: lani_production
    sslMode: require

redis:
  type: external
  external:
    host: your-elasticache.cache.amazonaws.com

autoscaling:
  web:
    enabled: true
    minReplicas: 5
    maxReplicas: 20
    targetCPUUtilizationPercentage: 70

resources:
  web:
    requests:
      memory: 1Gi
      cpu: 500m
    limits:
      memory: 2Gi
      cpu: 2000m

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: lani.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: lani-tls
      hosts:
        - lani.yourdomain.com

monitoring:
  enabled: true
  prometheus:
    enabled: true
  grafana:
    enabled: true

backup:
  enabled: true
  s3:
    enabled: true
    bucket: your-backup-bucket
    region: us-east-1

secrets:
  external: true
  externalSecretStore: aws-secrets-manager
```

### Deploy to Production

```bash
# Create namespace
kubectl create namespace lani-production

# Install with production values
helm install lani lani/lani \
  --namespace lani-production \
  --values production-values.yaml \
  --wait --timeout=10m

# Verify deployment
kubectl get pods -n lani-production
kubectl get ingress -n lani-production
```

## Monitoring and Observability

The chart includes built-in monitoring capabilities:

- **Prometheus Metrics**: Application and infrastructure metrics
- **Grafana Dashboards**: Pre-configured dashboards for monitoring
- **Health Checks**: Liveness, readiness, and startup probes
- **Logging**: Structured logging with configurable levels

## Backup and Recovery

Automated backup configuration:

```yaml
backup:
  enabled: true
  schedule: "0 2 * * *"  # Daily at 2 AM
  retention: 7  # Keep 7 days of backups
  s3:
    enabled: true
    bucket: your-backup-bucket
    region: us-east-1
```

## Troubleshooting

### Common Issues

1. **Pod Startup Issues**
   ```bash
   kubectl logs -n lani-production deployment/lani-web
   kubectl describe pod -n lani-production -l app.kubernetes.io/name=lani
   ```

2. **Database Connection Issues**
   ```bash
   kubectl exec -n lani-production deployment/lani-web -- rails db:migrate:status
   ```

3. **Ingress Issues**
   ```bash
   kubectl get ingress -n lani-production
   kubectl describe ingress -n lani-production lani-ingress
   ```

### Support

- **Documentation**: [Full Documentation](https://github.com/your-org/lani/tree/main/docs)
- **Issues**: [GitHub Issues](https://github.com/your-org/lani/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-org/lani/discussions)

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with `helm lint` and `helm template`
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
