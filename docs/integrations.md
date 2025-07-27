---
layout: default
title: "Integrations"
description: "External service integrations for Lani Platform"
---

# Integrations

Lani Platform integrates with multiple external services to provide comprehensive functionality. This guide covers setup and configuration for each integration.

## Available Integrations

<div class="feature-grid">
  <div class="feature-card">
    <div class="feature-icon">📊</div>
    <h3>OpenProject</h3>
    <p>Project management and work package synchronization</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💰</div>
    <h3>Maybe Finance</h3>
    <p>Financial data synchronization and budget management</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">📁</div>
    <h3>Nextcloud</h3>
    <p>File sharing and collaborative document management</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🗺️</div>
    <h3>Mapbox</h3>
    <p>Interactive maps and geospatial features</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🛒</div>
    <h3>Medusa</h3>
    <p>Headless e-commerce and product management</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💳</div>
    <h3>Stripe</h3>
    <p>Payment processing and subscription management</p>
  </div>
</div>

## OpenProject Integration

### Overview

Sync projects, work packages, and team data with OpenProject instances.

### Setup

1. **Get API Key**
   - Login to your OpenProject instance
   - Go to My Account → Access tokens
   - Create a new API key

2. **Configure Environment**
   ```bash
   export OPENPROJECT_API_KEY="your_api_key"
   export OPENPROJECT_URL="https://your-openproject.com"
   export ENABLE_OPENPROJECT_INTEGRATION=true
   ```

3. **Test Connection**
   ```bash
   rails console
   > ExternalApiService.new.test_openproject_connection
   ```

### Features

- **Project Sync**: Bidirectional project synchronization
- **Work Package Import**: Import tasks as work packages
- **Team Management**: Sync team members and roles
- **Status Updates**: Real-time status synchronization

### API Endpoints

```ruby
# Sync all projects
POST /api/v1/integrations/openproject/sync_projects

# Import specific project
POST /api/v1/integrations/openproject/import_project
{
  "openproject_id": 123,
  "import_tasks": true,
  "import_team": true
}

# Export project to OpenProject
POST /api/v1/integrations/openproject/export_project
{
  "project_id": 456,
  "create_work_packages": true
}
```

## Maybe Finance Integration

### Overview

Synchronize financial data, budgets, and transactions with Maybe Finance.

### Setup

1. **Get API Credentials**
   - Access your Maybe Finance account
   - Generate API credentials in Settings → API

2. **Configure Environment**
   ```bash
   export MAYBE_API_KEY="your_api_key"
   export MAYBE_URL="https://your-maybe.com"
   export ENABLE_MAYBE_INTEGRATION=true
   ```

3. **Initial Sync**
   ```bash
   rails console
   > ExternalApiService.new.sync_maybe_accounts
   ```

### Features

- **Account Sync**: Import bank accounts and balances
- **Transaction Import**: Sync financial transactions
- **Budget Management**: Two-way budget synchronization
- **Financial Reports**: Enhanced reporting with Maybe data

### Configuration

```yaml
# config/integrations/maybe.yml
maybe:
  sync_frequency: daily
  import_categories:
    - income
    - expenses
    - investments
  export_budgets: true
  auto_categorize: true
```

## Nextcloud Integration

### Overview

File sharing, collaboration, and document management through Nextcloud WebDAV.

### Setup

1. **Create App Password**
   - Login to Nextcloud
   - Go to Settings → Security
   - Generate app password for Lani

2. **Configure Environment**
   ```bash
   export NEXTCLOUD_URL="https://your-nextcloud.com"
   export NEXTCLOUD_USERNAME="your_username"
   export NEXTCLOUD_PASSWORD="your_app_password"
   export ENABLE_NEXTCLOUD_INTEGRATION=true
   ```

3. **Test WebDAV Connection**
   ```bash
   curl -u username:password \
        -X PROPFIND \
        https://your-nextcloud.com/remote.php/dav/files/username/
   ```

### Features

- **File Upload**: Direct file uploads to Nextcloud
- **Folder Management**: Project-based folder organization
- **Share Links**: Generate secure share links
- **Version Control**: File version management
- **Collaborative Editing**: Real-time document collaboration

### File Organization

```
/Lani Projects/
├── Project Name 1/
│   ├── Documents/
│   ├── Images/
│   └── Shared/
├── Project Name 2/
└── Templates/
```

## Mapbox Integration

### Overview

Interactive maps, geocoding, and location-based project management.

### Setup

1. **Get Access Token**
   - Create Mapbox account
   - Get access token from Account → Tokens

2. **Configure Environment**
   ```bash
   export MAPBOX_ACCESS_TOKEN="pk.your_token"
   export ENABLE_MAPBOX_INTEGRATION=true
   ```

3. **Configure Map Styles**
   ```javascript
   // config/mapbox.js
   const mapboxConfig = {
     style: 'mapbox://styles/mapbox/streets-v11',
     center: [-122.4194, 37.7749],
     zoom: 12
   };
   ```

### Features

- **Interactive Maps**: Project location visualization
- **Geocoding**: Address to coordinates conversion
- **Route Planning**: Distance and time calculations
- **Custom Markers**: Project-specific map markers
- **Geofencing**: Location-based notifications

### Map Customization

```javascript
// Custom map style
const customStyle = {
  "version": 8,
  "sources": {
    "projects": {
      "type": "geojson",
      "data": "/api/v1/projects/geojson"
    }
  },
  "layers": [
    {
      "id": "project-markers",
      "type": "circle",
      "source": "projects",
      "paint": {
        "circle-radius": 8,
        "circle-color": "#3b82f6"
      }
    }
  ]
};
```

## Medusa Integration

### Overview

Headless e-commerce platform integration for product management and sales.

### Setup

1. **Deploy Medusa Backend**
   ```bash
   npx create-medusa-app
   # Configure your Medusa instance
   ```

2. **Get API Key**
   ```bash
   # In your Medusa admin
   medusa user -e admin@example.com -p password
   # Get API key from admin panel
   ```

3. **Configure Environment**
   ```bash
   export MEDUSA_API_KEY="your_api_key"
   export MEDUSA_URL="https://your-medusa.com"
   export ENABLE_MEDUSA_INTEGRATION=true
   ```

### Features

- **Product Catalog**: Sync products and variants
- **Inventory Management**: Real-time stock updates
- **Order Processing**: Complete order lifecycle
- **Customer Management**: Customer data synchronization
- **Payment Integration**: Stripe payment processing

### Product Sync

```ruby
# Sync all products from Medusa
POST /api/v1/integrations/medusa/sync_products

# Import specific product
POST /api/v1/integrations/medusa/import_product
{
  "medusa_product_id": "prod_123",
  "sync_variants": true,
  "sync_inventory": true
}
```

## Stripe Integration

### Overview

Payment processing, subscription management, and billing integration.

### Setup

1. **Get API Keys**
   - Login to Stripe Dashboard
   - Get publishable and secret keys
   - Set up webhooks

2. **Configure Environment**
   ```bash
   export STRIPE_PUBLISHABLE_KEY="pk_test_..."
   export STRIPE_SECRET_KEY="sk_test_..."
   export STRIPE_WEBHOOK_SECRET="whsec_..."
   export ENABLE_STRIPE_PAYMENTS=true
   ```

3. **Configure Webhooks**
   ```bash
   # Webhook endpoint
   https://your-domain.com/api/v1/webhooks/stripe
   
   # Required events
   - payment_intent.succeeded
   - payment_intent.payment_failed
   - customer.subscription.created
   - customer.subscription.updated
   - customer.subscription.deleted
   ```

### Features

- **Payment Processing**: One-time and recurring payments
- **Subscription Management**: Multiple subscription plans
- **Customer Portal**: Self-service billing management
- **Refund Processing**: Automated refund handling
- **Tax Calculation**: Automatic tax computation

### Subscription Plans

```ruby
# config/stripe_plans.rb
STRIPE_PLANS = {
  starter: {
    price_id: 'price_starter',
    name: 'Starter Plan',
    amount: 2900, # $29.00
    interval: 'month'
  },
  professional: {
    price_id: 'price_professional',
    name: 'Professional Plan',
    amount: 9900, # $99.00
    interval: 'month'
  },
  enterprise: {
    price_id: 'price_enterprise',
    name: 'Enterprise Plan',
    amount: 29900, # $299.00
    interval: 'month'
  }
}
```

## Integration Management

### Admin Interface

Access integration settings through the admin panel:

1. **Navigate to Admin → Integrations**
2. **Configure each integration**
3. **Test connections**
4. **Monitor sync status**

### Monitoring

```ruby
# Check integration health
GET /api/v1/integrations/health

# Response
{
  "openproject": {
    "status": "connected",
    "last_sync": "2024-01-20T15:30:00Z",
    "projects_synced": 25
  },
  "maybe": {
    "status": "connected",
    "last_sync": "2024-01-20T14:00:00Z",
    "accounts_synced": 5
  },
  "nextcloud": {
    "status": "connected",
    "storage_used": "2.5GB",
    "files_synced": 150
  }
}
```

### Error Handling

```ruby
# Integration error logs
GET /api/v1/integrations/errors

# Retry failed sync
POST /api/v1/integrations/:service/retry
{
  "operation": "sync_projects",
  "retry_failed_only": true
}
```

## Troubleshooting

### Common Issues

#### Authentication Errors
```bash
# Test API credentials
curl -H "Authorization: Bearer $API_KEY" \
     https://api.service.com/test
```

#### Sync Failures
```bash
# Check sync logs
tail -f log/integrations.log

# Manual sync
rails console
> ExternalApiService.new.manual_sync('openproject')
```

#### Rate Limiting
```ruby
# Configure rate limiting
# config/integrations.yml
rate_limits:
  openproject: 100  # requests per hour
  maybe: 200
  nextcloud: 500
```

### Support

- **Integration Issues**: [GitHub Issues](https://github.com/your-org/lani/issues)
- **Service-Specific Help**: Check individual service documentation
- **Community Support**: [GitHub Discussions](https://github.com/your-org/lani/discussions)

---

<div class="footer-cta">
  <h2>Need help with integrations?</h2>
  <p>Check our troubleshooting guide or reach out to the community for support.</p>
  <a href="https://github.com/your-org/lani/discussions" class="btn btn-primary">Get Help</a>
</div>
