---
layout: default
title: "Getting Started"
description: "Quick start guide for the Lani Platform"
---

# Getting Started with Lani Platform

Welcome to Lani Platform! This guide will help you get up and running quickly with our comprehensive project management and collaboration platform.

## Prerequisites

Before you begin, ensure you have the following installed:

### For Docker Setup (Recommended)
- [Docker](https://docs.docker.com/get-docker/) 20.10+
- [Docker Compose](https://docs.docker.com/compose/install/) 2.0+

### For Local Development
- [Ruby](https://www.ruby-lang.org/en/downloads/) 3.1+
- [Rails](https://rubyonrails.org/) 7.0+
- [PostgreSQL](https://www.postgresql.org/download/) 13+
- [Redis](https://redis.io/download) 6+
- [Node.js](https://nodejs.org/) 18+
- [Yarn](https://yarnpkg.com/getting-started/install)

## Quick Start Options

### Option 1: Docker Setup (Recommended)

The fastest way to get Lani running is with Docker:

```bash
# Clone the repository
git clone https://github.com/your-org/lani.git
cd lani

# Start all services
docker-compose up -d

# Setup the database
docker-compose exec web rails db:setup

# Create sample data (optional)
docker-compose exec web rails db:seed

# Visit the application
open http://localhost:3000
```

### Option 2: Kubernetes with Helm

For production or staging environments:

```bash
# Add the Lani Helm repository
helm repo add lani https://your-org.github.io/lani/
helm repo update

# Install Lani Platform
helm install lani lani/lani \
  --namespace lani-production \
  --create-namespace \
  --set ingress.enabled=true \
  --set ingress.hosts[0].host=lani.yourdomain.com

# Check deployment status
kubectl get pods -n lani-production
```

### Option 3: Local Development

For active development and customization:

```bash
# Clone the repository
git clone https://github.com/your-org/lani.git
cd lani

# Install dependencies
bin/setup

# Start the development server
bin/dev

# In another terminal, start background jobs
bundle exec sidekiq

# Visit the application
open http://localhost:3000
```

## First Steps

### 1. Create Your Admin Account

When you first visit Lani, you'll be redirected to the sign-up page. Create your admin account:

1. Navigate to `http://localhost:3000`
2. Click "Sign up" 
3. Fill in your details
4. The first user automatically becomes an admin

### 2. Complete the Onboarding Wizard

Lani includes a comprehensive 7-step onboarding wizard:

1. **Welcome** - Introduction to Lani Platform
2. **Profile Setup** - Complete your user profile
3. **First Project** - Create your first project
4. **Team Invitations** - Invite team members
5. **Integrations** - Configure external services
6. **Features Tour** - Explore key features
7. **Completion** - You're ready to go!

### 3. Configure Integrations (Optional)

Lani integrates with several external services. Configure them in the admin panel:

#### OpenProject Integration
```bash
# Set environment variables
export OPENPROJECT_API_KEY="your_api_key"
export OPENPROJECT_URL="https://your-openproject.com"
export ENABLE_OPENPROJECT_INTEGRATION=true
```

#### Maybe Finance Integration
```bash
export MAYBE_API_KEY="your_api_key"
export MAYBE_URL="https://your-maybe.com"
export ENABLE_MAYBE_INTEGRATION=true
```

#### Nextcloud Integration
```bash
export NEXTCLOUD_URL="https://your-nextcloud.com"
export NEXTCLOUD_USERNAME="your_username"
export NEXTCLOUD_PASSWORD="your_password"
export ENABLE_NEXTCLOUD_INTEGRATION=true
```

#### Mapbox Integration
```bash
export MAPBOX_ACCESS_TOKEN="your_mapbox_token"
export ENABLE_MAPBOX_INTEGRATION=true
```

#### Stripe Payments
```bash
export STRIPE_PUBLISHABLE_KEY="pk_test_..."
export STRIPE_SECRET_KEY="sk_test_..."
export ENABLE_STRIPE_PAYMENTS=true
```

## Default Accounts

For testing and development, Lani creates default accounts:

| Role | Email | Password | Permissions |
|------|-------|----------|-------------|
| Admin | admin@lani.local | password | Full system access |
| Manager | manager@lani.local | password | Project management |
| Member | member@lani.local | password | Basic project access |

<div class="alert alert-warning">
<strong>Security Note:</strong> Change these default passwords immediately in production environments!
</div>

## Verification Steps

After setup, verify everything is working:

### 1. Check Services Status

**Docker Setup:**
```bash
docker-compose ps
```

**Kubernetes Setup:**
```bash
kubectl get pods -n lani-production
kubectl get services -n lani-production
```

**Local Setup:**
```bash
# Check Rails server
curl http://localhost:3000/health

# Check Redis
redis-cli ping

# Check PostgreSQL
psql -h localhost -U lani_user -d lani_development -c "SELECT version();"
```

### 2. Test Core Features

1. **Authentication**: Sign in with your admin account
2. **Projects**: Create a new project
3. **Tasks**: Add tasks to your project
4. **Team**: Invite a team member
5. **Budget**: Set up a project budget
6. **Files**: Upload a file (if Nextcloud is configured)

### 3. Check Background Jobs

```bash
# Docker
docker-compose exec web bundle exec sidekiq-web

# Local
bundle exec sidekiq-web
```

Visit `http://localhost:4567` to see the Sidekiq dashboard.

## Troubleshooting

### Common Issues

#### Database Connection Issues
```bash
# Check PostgreSQL is running
docker-compose ps postgres

# Reset database
docker-compose exec web rails db:reset
```

#### Redis Connection Issues
```bash
# Check Redis is running
docker-compose ps redis

# Test Redis connection
docker-compose exec redis redis-cli ping
```

#### Asset Issues
```bash
# Rebuild assets
docker-compose exec web rails assets:precompile

# Or for local development
yarn build
```

#### Permission Issues
```bash
# Fix file permissions
sudo chown -R $USER:$USER .
chmod +x bin/*
```

### Getting Help

If you encounter issues:

1. **Check the logs**:
   ```bash
   # Docker
   docker-compose logs -f web
   
   # Local
   tail -f log/development.log
   ```

2. **Search existing issues**: [GitHub Issues](https://github.com/your-org/lani/issues)

3. **Ask for help**: [GitHub Discussions](https://github.com/your-org/lani/discussions)

4. **Report bugs**: [New Issue](https://github.com/your-org/lani/issues/new)

## Next Steps

Now that you have Lani running:

1. **[Configuration Guide](configuration/)** - Customize Lani for your needs
2. **[Deployment Guide](deployment/)** - Deploy to production
3. **[API Documentation](api/)** - Integrate with external systems
4. **[Integration Guides](integrations/)** - Connect external services
5. **[Contributing Guide](contributing/)** - Help improve Lani

## Performance Tips

### For Development
- Use Docker for consistent environments
- Enable caching in development for better performance
- Use `bin/dev` for automatic asset reloading

### For Production
- Use Redis for caching and sessions
- Configure proper database connection pooling
- Enable asset compression and CDN
- Set up monitoring and logging

---

<div class="footer-cta">
  <h2>Ready to dive deeper?</h2>
  <p>Explore our comprehensive configuration options and deployment guides.</p>
  <a href="configuration/" class="btn btn-primary">Configuration Guide</a>
</div>
