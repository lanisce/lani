---
layout: default
title: "Deployment Guide"
description: "Production deployment options for Lani Platform"
---

# Deployment Guide

This guide covers various deployment options for the Lani Platform, from simple Docker setups to enterprise Kubernetes deployments.

## Deployment Options

### 🐳 Docker Compose (Simple)

Perfect for small teams and development environments.

```bash
# Clone and setup
git clone https://github.com/your-org/lani.git
cd lani

# Configure environment
cp .env.example .env
# Edit .env with your configuration

# Deploy
docker-compose -f docker-compose.prod.yml up -d

# Setup database
docker-compose exec web rails db:setup
```

### ☸️ Kubernetes with Helm (Recommended)

Enterprise-ready deployment with auto-scaling and high availability.

```bash
# Add Helm repository
helm repo add lani https://your-org.github.io/lani/
helm repo update

# Create namespace
kubectl create namespace lani-production

# Install with custom values
helm install lani lani/lani \
  --namespace lani-production \
  --values production-values.yaml
```

### 🚀 One-Click Deployments

Deploy to popular cloud platforms with one click:

[![Deploy to DigitalOcean](https://www.deploytodo.com/do-btn-blue.svg)](https://cloud.digitalocean.com/apps/new?repo=https://github.com/your-org/lani/tree/main)

[![Deploy to Railway](https://railway.app/button.svg)](https://railway.app/new/template/lani-platform)

[![Deploy to Render](https://render.com/images/deploy-to-render-button.svg)](https://render.com/deploy?repo=https://github.com/your-org/lani)

## Production Configuration

### Environment Variables

Essential production environment variables:

```bash
# Application
RAILS_ENV=production
SECRET_KEY_BASE=your_secret_key_base
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true

# Database
DATABASE_URL=postgres://user:pass@host:5432/lani_production
REDIS_URL=redis://host:6379/0

# External Services
OPENPROJECT_API_KEY=your_key
MAYBE_API_KEY=your_key
NEXTCLOUD_URL=https://your-nextcloud.com
MAPBOX_ACCESS_TOKEN=your_token
STRIPE_SECRET_KEY=sk_live_...

# Email (SMTP)
SMTP_HOST=smtp.mailgun.org
SMTP_PORT=587
SMTP_USERNAME=your_username
SMTP_PASSWORD=your_password
SMTP_DOMAIN=yourdomain.com

# Security
FORCE_SSL=true
ALLOWED_HOSTS=yourdomain.com,www.yourdomain.com
```

### SSL/TLS Configuration

#### With Kubernetes and cert-manager

```yaml
# values.yaml
ingress:
  enabled: true
  annotations:
    cert-manager.io/cluster-issuer: "letsencrypt-prod"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
  hosts:
    - host: lani.yourdomain.com
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: lani-tls
      hosts:
        - lani.yourdomain.com
```

#### With Docker Compose and Traefik

```yaml
# docker-compose.prod.yml
services:
  web:
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.lani.rule=Host(`lani.yourdomain.com`)"
      - "traefik.http.routers.lani.tls.certresolver=letsencrypt"
```

## Kubernetes Deployment

### Prerequisites

- Kubernetes cluster (1.20+)
- Helm 3.0+
- kubectl configured
- cert-manager (for SSL)
- Ingress controller (nginx recommended)

### Installation Steps

1. **Add Helm Repository**
   ```bash
   helm repo add lani https://your-org.github.io/lani/
   helm repo update
   ```

2. **Create Values File**
   ```yaml
   # production-values.yaml
   replicaCount: 3
   
   image:
     tag: "latest"
   
   postgresql:
     type: external
     host: your-postgres-host
     database: lani_production
     username: lani_user
     existingSecret: lani-db-secret
   
   redis:
     type: external
     host: your-redis-host
     existingSecret: lani-redis-secret
   
   ingress:
     enabled: true
     className: nginx
     annotations:
       cert-manager.io/cluster-issuer: letsencrypt-prod
       nginx.ingress.kubernetes.io/ssl-redirect: "true"
     hosts:
       - host: lani.yourdomain.com
         paths:
           - path: /
             pathType: Prefix
     tls:
       - secretName: lani-tls
         hosts:
           - lani.yourdomain.com
   
   autoscaling:
     enabled: true
     minReplicas: 3
     maxReplicas: 10
     targetCPUUtilizationPercentage: 70
   
   resources:
     limits:
       cpu: 1000m
       memory: 2Gi
     requests:
       cpu: 500m
       memory: 1Gi
   ```

3. **Create Secrets**
   ```bash
   # Database secret
   kubectl create secret generic lani-db-secret \
     --from-literal=password=your_db_password \
     --namespace lani-production
   
   # Redis secret
   kubectl create secret generic lani-redis-secret \
     --from-literal=password=your_redis_password \
     --namespace lani-production
   
   # Application secrets
   kubectl create secret generic lani-app-secret \
     --from-literal=secret-key-base=your_secret_key \
     --from-literal=openproject-api-key=your_key \
     --from-literal=stripe-secret-key=your_key \
     --namespace lani-production
   ```

4. **Deploy**
   ```bash
   helm install lani lani/lani \
     --namespace lani-production \
     --create-namespace \
     --values production-values.yaml
   ```

5. **Verify Deployment**
   ```bash
   kubectl get pods -n lani-production
   kubectl get services -n lani-production
   kubectl get ingress -n lani-production
   ```

### Monitoring and Logging

#### Prometheus and Grafana

```yaml
# monitoring-values.yaml
monitoring:
  enabled: true
  serviceMonitor:
    enabled: true
  prometheusRule:
    enabled: true
```

#### Centralized Logging

```yaml
# logging-values.yaml
logging:
  enabled: true
  fluentd:
    enabled: true
    elasticsearch:
      host: your-elasticsearch-host
```

## Database Setup

### PostgreSQL Configuration

#### Managed Database (Recommended)

Use managed PostgreSQL services:
- **AWS RDS**
- **Google Cloud SQL**
- **Azure Database**
- **DigitalOcean Managed Databases**

#### Self-Hosted PostgreSQL

```sql
-- Create database and user
CREATE DATABASE lani_production;
CREATE USER lani_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE lani_production TO lani_user;

-- Performance tuning
ALTER SYSTEM SET shared_preload_libraries = 'pg_stat_statements';
ALTER SYSTEM SET max_connections = 200;
ALTER SYSTEM SET shared_buffers = '256MB';
ALTER SYSTEM SET effective_cache_size = '1GB';
```

### Redis Configuration

#### Managed Redis (Recommended)

Use managed Redis services:
- **AWS ElastiCache**
- **Google Cloud Memorystore**
- **Azure Cache for Redis**
- **DigitalOcean Managed Redis**

#### Self-Hosted Redis

```bash
# redis.conf
maxmemory 512mb
maxmemory-policy allkeys-lru
save 900 1
save 300 10
save 60 10000
```

## Security Considerations

### Network Security

```yaml
# Network policies
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: lani-network-policy
spec:
  podSelector:
    matchLabels:
      app: lani
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: kube-system
```

### Pod Security

```yaml
# Pod security context
securityContext:
  runAsNonRoot: true
  runAsUser: 1000
  fsGroup: 1000
  seccompProfile:
    type: RuntimeDefault
  
containerSecurityContext:
  allowPrivilegeEscalation: false
  readOnlyRootFilesystem: true
  capabilities:
    drop:
    - ALL
```

### Secret Management

Use external secret management:
- **AWS Secrets Manager**
- **Google Secret Manager**
- **Azure Key Vault**
- **HashiCorp Vault**

```yaml
# External Secrets Operator
apiVersion: external-secrets.io/v1beta1
kind: SecretStore
metadata:
  name: vault-backend
spec:
  provider:
    vault:
      server: "https://vault.example.com"
      path: "secret"
      version: "v2"
```

## Performance Optimization

### Caching Strategy

```yaml
# Redis configuration for caching
redis:
  cache:
    enabled: true
    ttl: 3600
  sessions:
    enabled: true
    ttl: 86400
```

### Database Optimization

```sql
-- Create indexes for performance
CREATE INDEX CONCURRENTLY idx_projects_user_id ON projects(user_id);
CREATE INDEX CONCURRENTLY idx_tasks_project_id ON tasks(project_id);
CREATE INDEX CONCURRENTLY idx_tasks_status ON tasks(status);
```

### CDN Configuration

```yaml
# CloudFront or CloudFlare
assets:
  cdn:
    enabled: true
    domain: assets.yourdomain.com
    s3_bucket: your-assets-bucket
```

## Backup and Recovery

### Database Backups

```bash
# Automated backup script
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump $DATABASE_URL | gzip > backup_$DATE.sql.gz
aws s3 cp backup_$DATE.sql.gz s3://your-backup-bucket/
```

### File Storage Backups

```yaml
# Kubernetes CronJob for backups
apiVersion: batch/v1
kind: CronJob
metadata:
  name: lani-backup
spec:
  schedule: "0 2 * * *"
  jobTemplate:
    spec:
      template:
        spec:
          containers:
          - name: backup
            image: lani/backup:latest
            command:
            - /backup.sh
```

## Scaling

### Horizontal Pod Autoscaling

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: lani-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lani
  minReplicas: 3
  maxReplicas: 20
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
  - type: Resource
    resource:
      name: memory
      target:
        type: Utilization
        averageUtilization: 80
```

### Vertical Pod Autoscaling

```yaml
apiVersion: autoscaling.k8s.io/v1
kind: VerticalPodAutoscaler
metadata:
  name: lani-vpa
spec:
  targetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: lani
  updatePolicy:
    updateMode: "Auto"
```

## Troubleshooting

### Common Issues

#### Pod Startup Issues
```bash
kubectl describe pod <pod-name> -n lani-production
kubectl logs <pod-name> -n lani-production --previous
```

#### Database Connection Issues
```bash
kubectl exec -it <pod-name> -n lani-production -- rails console
# Test database connection
ActiveRecord::Base.connection.execute("SELECT 1")
```

#### Performance Issues
```bash
# Check resource usage
kubectl top pods -n lani-production
kubectl top nodes

# Check HPA status
kubectl get hpa -n lani-production
```

### Health Checks

```yaml
# Kubernetes health checks
livenessProbe:
  httpGet:
    path: /health
    port: 3000
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 3000
  initialDelaySeconds: 5
  periodSeconds: 5
```

---

<div class="footer-cta">
  <h2>Need help with deployment?</h2>
  <p>Check our troubleshooting guide or reach out to the community.</p>
  <a href="https://github.com/your-org/lani/discussions" class="btn btn-primary">Get Support</a>
</div>
