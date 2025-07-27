# Production Deployment Guide

## Overview

This guide covers deploying the Lani platform to production environments using Docker Compose, Kubernetes, or Helm charts. The platform supports multiple deployment strategies with comprehensive configuration options.

## Prerequisites

### System Requirements

- **CPU**: 4+ cores recommended
- **Memory**: 8GB+ RAM recommended
- **Storage**: 100GB+ SSD recommended
- **Network**: HTTPS/SSL certificate required

### Software Requirements

- Docker 20.10+
- Docker Compose 2.0+
- Kubernetes 1.24+ (for K8s deployment)
- Helm 3.8+ (for Helm deployment)
- PostgreSQL 15+ (external or containerized)
- Redis 7+ (external or containerized)

## Environment Variables

### Required Environment Variables

```bash
# Rails Configuration
RAILS_ENV=production
SECRET_KEY_BASE=your-secret-key-base
RAILS_MASTER_KEY=your-master-key

# Database Configuration
DATABASE_URL=postgres://user:password@host:5432/lani_production
POSTGRES_PASSWORD=secure-password

# Redis Configuration
REDIS_URL=redis://redis:6379/0
REDIS_PASSWORD=secure-redis-password

# Payment Processing (Stripe)
STRIPE_SECRET_KEY=sk_live_...
STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

# External API Integrations
MAPBOX_ACCESS_TOKEN=pk.eyJ1...
OPENPROJECT_API_URL=https://your-openproject.com/api/v3
OPENPROJECT_API_KEY=your-api-key
MAYBE_API_URL=https://your-maybe-instance.com/api
MAYBE_API_KEY=your-maybe-api-key
NEXTCLOUD_URL=https://your-nextcloud.com
NEXTCLOUD_USERNAME=api-user
NEXTCLOUD_PASSWORD=api-password
MEDUSA_API_URL=https://your-medusa.com
MEDUSA_API_KEY=your-medusa-key
```

### Optional Environment Variables

```bash
# Monitoring and Logging
NEW_RELIC_LICENSE_KEY=your-license-key
DATADOG_API_KEY=your-datadog-key
SENTRY_DSN=https://your-sentry-dsn

# Email Configuration
SMTP_HOST=smtp.example.com
SMTP_PORT=587
SMTP_USERNAME=noreply@lani.dev
SMTP_PASSWORD=smtp-password

# Storage Configuration
AWS_ACCESS_KEY_ID=your-access-key
AWS_SECRET_ACCESS_KEY=your-secret-key
AWS_REGION=us-east-1
AWS_S3_BUCKET=lani-production-storage

# Security
ALLOWED_HOSTS=lani.dev,www.lani.dev
CORS_ALLOWED_ORIGINS=https://lani.dev,https://www.lani.dev
```

## Docker Compose Deployment

### 1. Prepare Environment

```bash
# Clone repository
git clone https://github.com/your-org/lani.git
cd lani

# Create environment file
cp .env.example .env.production
# Edit .env.production with your configuration

# Create required directories
mkdir -p nginx/ssl
mkdir -p backups
```

### 2. SSL Certificate Setup

```bash
# Using Let's Encrypt with Certbot
docker-compose -f docker-compose.production.yml run --rm certbot \
  certonly --webroot --webroot-path=/var/www/certbot \
  --email admin@lani.dev --agree-tos --no-eff-email \
  -d lani.dev -d www.lani.dev

# Or copy your existing certificates
cp your-certificate.crt nginx/ssl/
cp your-private-key.key nginx/ssl/
```

### 3. Database Setup

```bash
# Create and migrate database
docker-compose -f docker-compose.production.yml run --rm web \
  rails db:create db:migrate

# Seed initial data (optional)
docker-compose -f docker-compose.production.yml run --rm web \
  rails db:seed
```

### 4. Deploy Services

```bash
# Start all services
docker-compose -f docker-compose.production.yml up -d

# Check service health
docker-compose -f docker-compose.production.yml ps
docker-compose -f docker-compose.production.yml logs web
```

### 5. Verify Deployment

```bash
# Health check
curl -f https://lani.dev/health

# Application check
curl -f https://lani.dev/api/health
```

## Kubernetes Deployment

### 1. Prepare Kubernetes Cluster

```bash
# Ensure kubectl is configured
kubectl cluster-info

# Create namespace
kubectl create namespace lani-production

# Set default namespace
kubectl config set-context --current --namespace=lani-production
```

### 2. Configure Secrets

```bash
# Create secrets from files
kubectl create secret generic lani-secrets \
  --from-env-file=.env.production

# Create TLS secret for ingress
kubectl create secret tls lani-tls \
  --cert=nginx/ssl/certificate.crt \
  --key=nginx/ssl/private.key
```

### 3. Deploy with Kubernetes Manifests

```bash
# Apply all manifests
kubectl apply -f k8s/

# Check deployment status
kubectl get pods
kubectl get services
kubectl get ingress
```

### 4. Database Migration

```bash
# Run migrations
kubectl run lani-migrate --rm -i --restart=Never \
  --image=ghcr.io/your-org/lani:latest \
  --env-from=secret/lani-secrets \
  -- rails db:migrate

# Seed data (if needed)
kubectl run lani-seed --rm -i --restart=Never \
  --image=ghcr.io/your-org/lani:latest \
  --env-from=secret/lani-secrets \
  -- rails db:seed
```

## Helm Deployment

### 1. Add Helm Repository

```bash
# Add Lani Helm repository
helm repo add lani https://charts.lani.dev
helm repo update
```

### 2. Configure Values

```yaml
# values.production.yaml
global:
  environment: production
  domain: lani.dev

image:
  repository: ghcr.io/your-org/lani
  tag: "latest"
  pullPolicy: IfNotPresent

ingress:
  enabled: true
  className: nginx
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-prod
  hosts:
    - host: lani.dev
      paths:
        - path: /
          pathType: Prefix
  tls:
    - secretName: lani-tls
      hosts:
        - lani.dev

postgresql:
  enabled: true
  auth:
    database: lani_production
    username: postgres
    existingSecret: lani-postgresql-secret
  primary:
    persistence:
      size: 100Gi

redis:
  enabled: true
  auth:
    existingSecret: lani-redis-secret
  master:
    persistence:
      size: 10Gi

externalSecrets:
  enabled: true
  secretStore:
    provider: aws
    region: us-east-1
```

### 3. Deploy with Helm

```bash
# Install Lani platform
helm install lani lani/lani \
  -f values.production.yaml \
  --namespace lani-production \
  --create-namespace

# Upgrade deployment
helm upgrade lani lani/lani \
  -f values.production.yaml \
  --namespace lani-production
```

### 4. Verify Helm Deployment

```bash
# Check Helm release
helm status lani -n lani-production

# Check resources
kubectl get all -n lani-production
```

## Monitoring and Maintenance

### Health Checks

```bash
# Application health
curl -f https://lani.dev/health

# Database connectivity
curl -f https://lani.dev/api/health/database

# Redis connectivity
curl -f https://lani.dev/api/health/redis

# External services
curl -f https://lani.dev/api/health/integrations
```

### Backup Procedures

```bash
# Database backup
kubectl exec -it deployment/postgresql -- \
  pg_dump -U postgres lani_production > backup-$(date +%Y%m%d).sql

# Redis backup
kubectl exec -it deployment/redis -- \
  redis-cli --rdb /data/backup-$(date +%Y%m%d).rdb

# File storage backup (if using persistent volumes)
kubectl exec -it deployment/lani-web -- \
  tar -czf /tmp/storage-backup-$(date +%Y%m%d).tar.gz /app/storage
```

### Scaling

```bash
# Scale web application
kubectl scale deployment lani-web --replicas=3

# Scale Sidekiq workers
kubectl scale deployment lani-sidekiq --replicas=2

# Using Helm
helm upgrade lani lani/lani \
  --set replicaCount=3 \
  --set sidekiq.replicaCount=2
```

### Updates and Rollbacks

```bash
# Update to new version
helm upgrade lani lani/lani \
  --set image.tag=v1.2.0

# Rollback to previous version
helm rollback lani 1

# Check rollout status
kubectl rollout status deployment/lani-web
```

## Troubleshooting

### Common Issues

1. **Database Connection Issues**
   ```bash
   # Check database pod
   kubectl logs deployment/postgresql
   
   # Test connection
   kubectl exec -it deployment/lani-web -- \
     rails runner "puts ActiveRecord::Base.connection.active?"
   ```

2. **Redis Connection Issues**
   ```bash
   # Check Redis pod
   kubectl logs deployment/redis
   
   # Test connection
   kubectl exec -it deployment/lani-web -- \
     rails runner "puts Redis.new.ping"
   ```

3. **SSL Certificate Issues**
   ```bash
   # Check certificate status
   kubectl describe certificate lani-tls
   
   # Check cert-manager logs
   kubectl logs -n cert-manager deployment/cert-manager
   ```

4. **Application Errors**
   ```bash
   # Check application logs
   kubectl logs deployment/lani-web
   
   # Check Sidekiq logs
   kubectl logs deployment/lani-sidekiq
   ```

### Performance Tuning

1. **Database Optimization**
   ```yaml
   postgresql:
     primary:
       resources:
         requests:
           memory: 2Gi
           cpu: 1000m
         limits:
           memory: 4Gi
           cpu: 2000m
   ```

2. **Redis Optimization**
   ```yaml
   redis:
     master:
       resources:
         requests:
           memory: 512Mi
           cpu: 500m
         limits:
           memory: 1Gi
           cpu: 1000m
   ```

3. **Application Scaling**
   ```yaml
   replicaCount: 3
   resources:
     requests:
       memory: 1Gi
       cpu: 500m
     limits:
       memory: 2Gi
       cpu: 1000m
   ```

## Security Considerations

### Network Security

- Use network policies to restrict pod-to-pod communication
- Enable TLS for all external communications
- Use service mesh (Istio) for advanced security features

### Secret Management

- Use external secret management (AWS Secrets Manager, HashiCorp Vault)
- Rotate secrets regularly
- Use least-privilege access principles

### Container Security

- Use non-root containers
- Scan images for vulnerabilities
- Use Pod Security Standards

### Monitoring and Alerting

- Set up comprehensive monitoring (Prometheus, Grafana)
- Configure alerting for critical issues
- Monitor security events and anomalies

## Support and Maintenance

### Regular Maintenance Tasks

1. **Daily**
   - Check application health
   - Monitor error rates
   - Review security alerts

2. **Weekly**
   - Update dependencies
   - Review performance metrics
   - Backup verification

3. **Monthly**
   - Security patches
   - Capacity planning
   - Disaster recovery testing

### Getting Help

- Documentation: https://docs.lani.dev
- Support: support@lani.dev
- Community: https://community.lani.dev
- GitHub Issues: https://github.com/your-org/lani/issues
