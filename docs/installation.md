# Installation Guide

This guide will help you set up the Lani Platform on your local development environment or production server.

## Prerequisites

### System Requirements
- **Docker** 20.10+ and **Docker Compose** 2.0+
- **Git** for version control
- **Node.js** 18+ and **Yarn** (for asset compilation)
- **Ruby** 3.1+ (if running without Docker)

### External Service Accounts (Optional)
- **OpenProject** account and API key for project management integration
- **Maybe Finance** account and API key for financial data sync
- **Nextcloud** instance with WebDAV access for file management
- **Mapbox** account and access token for geospatial features

## Quick Installation (Docker)

### 1. Clone the Repository
```bash
git clone https://github.com/your-org/lani.git
cd lani
```

### 2. Environment Setup
```bash
# Copy environment template
cp .env.example .env

# Edit environment variables
nano .env
```

### 3. Start Services
```bash
# Build and start all services
docker-compose up --build

# Or run in background
docker-compose up -d --build
```

### 4. Database Setup
```bash
# Create and migrate database
docker-compose exec web rails db:create db:migrate

# Seed with sample data
docker-compose exec web rails db:seed
```

### 5. Access the Application
- **Web Interface**: http://localhost:3001
- **Admin Dashboard**: http://localhost:3001/admin
- **API Endpoints**: http://localhost:3001/api/v1

## Manual Installation (Without Docker)

### 1. Install Dependencies
```bash
# Install Ruby dependencies
bundle install

# Install Node.js dependencies
yarn install
```

### 2. Database Setup
```bash
# Configure PostgreSQL
sudo -u postgres createdb lani_development
sudo -u postgres createuser lani

# Run migrations
rails db:create db:migrate db:seed
```

### 3. Start Services
```bash
# Start Redis (required for background jobs)
redis-server

# Start Sidekiq (background job processor)
bundle exec sidekiq

# Start Rails server
rails server -p 3001
```

## Configuration

### Environment Variables
Create a `.env` file with the following variables:

```bash
# Database Configuration
DATABASE_URL=postgresql://lani:password@localhost:5432/lani_development
REDIS_URL=redis://localhost:6379/0

# External API Keys
OPENPROJECT_BASE_URL=https://your-openproject.com
OPENPROJECT_API_KEY=your_api_key_here

MAYBE_BASE_URL=https://maybe.co
MAYBE_API_KEY=your_maybe_api_key

NEXTCLOUD_BASE_URL=https://your-nextcloud.com
NEXTCLOUD_USERNAME=your_username
NEXTCLOUD_PASSWORD=your_password

MAPBOX_ACCESS_TOKEN=your_mapbox_token

# Authentication
SECRET_KEY_BASE=generate_with_rails_secret
DEVISE_SECRET_KEY=generate_with_rails_secret

# Email Configuration (Optional)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USERNAME=your_email@gmail.com
SMTP_PASSWORD=your_app_password
```

### Generate Secret Keys
```bash
# Generate secret keys
rails secret
# Copy output to SECRET_KEY_BASE and DEVISE_SECRET_KEY
```

## Default User Accounts

After seeding the database, you can log in with these accounts:

| Role | Email | Password |
|------|-------|----------|
| Admin | admin@lani.dev | password123 |
| Project Manager | pm@lani.dev | password123 |
| Member | alice@lani.dev | password123 |
| Member | bob@lani.dev | password123 |
| Viewer | viewer@lani.dev | password123 |

## Verification

### Health Check
Visit http://localhost:3001/health to verify the application is running correctly.

### Feature Tests
```bash
# Run test suite
docker-compose exec web rspec

# Test external API connections
docker-compose exec web rails console
> ExternalApiService.new.openproject.projects
> ExternalApiService.new.maybe.budgets
```

## Troubleshooting

### Common Issues

**Port Already in Use**
```bash
# Check what's using the port
lsof -i :3001

# Kill the process or change the port in docker-compose.yml
```

**Database Connection Issues**
```bash
# Reset database
docker-compose exec web rails db:drop db:create db:migrate db:seed
```

**Asset Compilation Issues**
```bash
# Rebuild assets
docker-compose exec web rails assets:precompile
```

**External API Connection Issues**
- Verify API keys are correct in `.env`
- Check network connectivity to external services
- Review logs: `docker-compose logs web`

### Getting Help
- Check the [troubleshooting guide](troubleshooting.md)
- Review application logs: `docker-compose logs web`
- Create an issue on GitHub with error details

## Next Steps

1. **Configure External APIs**: Set up OpenProject, Maybe, and other integrations
2. **Customize Settings**: Review admin dashboard for system configuration
3. **Create Projects**: Start using the platform with your first project
4. **Invite Users**: Add team members and assign appropriate roles

For detailed feature documentation, see the [Quick Start Guide](quick-start.md).
