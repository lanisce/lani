# Lani Platform - Windsurf Development Context

> **Last Updated:** 2025-07-27T18:06:08+02:00  
> **Status:** Phase 4 - Documentation Complete, Ready for Final Polish

## 🎯 Project Overview

The Lani platform is a unified project management platform that **directly reuses UI/UX components** from established open-source projects while integrating their **real APIs** for seamless data synchronization. This approach provides users with familiar interfaces while maintaining powerful integration capabilities.

### Core Philosophy
- **Direct UI/UX Reuse**: Not just inspiration, but actual component patterns from OpenProject, Maybe Finance, Nextcloud, and Medusa
- **Real API Integration**: Bidirectional sync with external services using official APIs
- **Modular Rails Architecture**: Service objects, Pundit policies, Hotwire for reactive UI
- **Docker-First Development**: Consistent environment with PostgreSQL, Redis, Sidekiq, Keycloak

## 🏗️ Technical Architecture

### Backend Stack
- **Ruby on Rails 7.0.4** (downgraded due to Logger compatibility issues)
- **PostgreSQL** - Primary database
- **Redis** - Caching and job queue
- **Sidekiq** - Background job processing
- **Pundit** - Authorization framework
- **Devise** - Authentication

### Frontend Stack
- **Hotwire** (Turbo + Stimulus) - Reactive web apps without heavy JS frameworks
- **Tailwind CSS** - Utility-first styling
- **Importmap** - Modern JavaScript module management
- **OpenProject-style inline editing** - Stimulus controllers for seamless editing

### External Integrations
- **OpenProject API v3** - Project and work package management
- **Maybe Finance API v1** - Budget and transaction synchronization
- **Nextcloud WebDAV** - File sharing and collaboration
- **Mapbox API** - Interactive maps and geospatial features
- **Medusa API** - E-commerce integration (planned)

## 📁 Key File Locations

### Core Application Files
```
app/
├── controllers/
│   ├── application_controller.rb          # Base controller with Pundit
│   ├── projects_controller.rb             # Main project CRUD
│   ├── tasks_controller.rb                # Nested task management
│   ├── project_budgets_controller.rb      # Financial management
│   ├── project_transactions_controller.rb # Transaction handling
│   ├── api_sync_controller.rb             # External API synchronization
│   └── admin/                             # Admin dashboard namespace
├── models/
│   ├── application_record.rb              # Base model class
│   ├── user.rb                           # Devise user with roles
│   ├── project.rb                        # Core project model
│   ├── task.rb                           # Task management
│   ├── budget.rb                         # Financial budgets
│   └── transaction.rb                    # Financial transactions
├── services/
│   ├── external_api_service.rb           # Unified API client service
│   ├── mapbox_service.rb                 # Geospatial features
│   └── nextcloud_service.rb              # File collaboration
├── policies/
│   ├── application_policy.rb             # Base Pundit policy
│   ├── project_policy.rb                 # Project authorization
│   ├── task_policy.rb                    # Task permissions
│   ├── budget_policy.rb                  # Financial access control
│   └── transaction_policy.rb             # Transaction permissions
└── javascript/controllers/
    ├── inline_edit_controller.js         # OpenProject-style editing
    └── mapbox_controller.js              # Interactive maps
```

### Configuration & Setup
```
config/
├── database.yml                          # PostgreSQL configuration
├── routes.rb                            # Application routing
├── application.rb                       # Rails application config
└── initializers/
    ├── devise.rb                        # Authentication setup
    └── pundit.rb                        # Authorization config

docker-compose.yml                        # Development environment
bin/
├── setup                                # Initial project setup
└── dev                                  # Development server launcher
Procfile.dev                             # Development processes
```

### Documentation
```
docs/
├── README.md                            # Documentation index
├── installation.md                     # Setup instructions
├── quick-start.md                       # User onboarding
├── features/
│   ├── project-management.md            # OpenProject integration
│   └── financial-management.md          # Maybe Finance integration
└── integrations/
    ├── openproject.md                   # API sync guide
    ├── maybe.md                         # Financial data sync
    ├── nextcloud.md                     # File collaboration
    └── mapbox.md                        # Geospatial features
```

## 🔑 Critical Implementation Details

### Rails Logger Compatibility Fix
**Issue**: Rails 7.0.8.7 + concurrent-ruby >= 1.3.5 breaks due to missing logger dependency  
**Solution**: Added `require 'logger'` before Rails loads in `config/boot.rb`  
**Reference**: https://github.com/rails/rails/issues/54271

### Docker Development Setup
- **Rails Server**: Port 3001 (to avoid conflicts)
- **PostgreSQL**: Port 5432
- **Redis**: Port 6379
- **Keycloak**: Port 8080

### Database Schema
```sql
-- Core tables created and populated
users                    # Devise authentication + roles
projects                 # Main project entities with geospatial support
project_memberships      # User-project associations with roles
tasks                    # Nested task management
budgets                  # Financial budget tracking
transactions            # Income/expense records
```

### User Roles & Permissions
- **Admin**: Full system access, user management
- **Project Manager**: Create/manage projects, assign tasks, financial oversight
- **Member**: Task management, file access, limited financial view
- **Viewer**: Read-only access to assigned projects

## 🎨 UI/UX Component Reuse

### OpenProject Integration
- **Inline Editing**: Stimulus controller with display/edit modes
- **Task Management**: Status badges, priority indicators, assignment UI
- **Work Package Patterns**: Consistent with OpenProject v13+ interface

### Maybe Finance Integration
- **Budget Cards**: Progress bars, color-coded status, quick actions
- **Transaction Rows**: Category icons, amount styling, metadata display
- **Financial Dashboard**: Clean, modern interface matching Maybe's design

### Implementation Files
```javascript
// app/javascript/controllers/inline_edit_controller.js
// OpenProject-style inline editing with keyboard shortcuts

// app/views/shared/_inline_edit_field.html.erb
// Reusable ERB partial for inline editing

// app/views/shared/_maybe_budget_card.html.erb
// Maybe Finance-style budget visualization

// app/views/shared/_maybe_transaction_row.html.erb
// Transaction display matching Maybe's interface
```

## 🔄 API Integration Status

### Completed Integrations
- ✅ **OpenProject API v3**: Bidirectional project/task sync
- ✅ **Maybe Finance API**: Budget and transaction synchronization
- ✅ **Nextcloud WebDAV**: File sharing and collaboration
- ✅ **Mapbox API**: Interactive maps with geocoding

### Service Implementation
```ruby
# app/services/external_api_service.rb
class ExternalApiService
  def self.openproject_client    # HTTParty client for OpenProject
  def self.maybe_client          # HTTParty client for Maybe Finance
  def self.nextcloud_client      # WebDAV client for file operations
  def self.mapbox_client         # Mapbox API integration
end

# app/controllers/api_sync_controller.rb
# Handles bidirectional synchronization with external APIs
```

## 🚀 Development Workflow

### Starting Development
```bash
# Clone and setup
git clone https://github.com/your-org/lani.git
cd lani

# Start all services
docker-compose up --build

# Setup database (first time)
docker-compose exec web rails db:create db:migrate db:seed

# Access application
open http://localhost:3001
```

### Test Accounts
| Role | Email | Password |
|------|-------|----------|
| Admin | admin@lani.dev | password123 |
| Project Manager | pm@lani.dev | password123 |
| Team Member | alice@lani.dev | password123 |
| Viewer | viewer@lani.dev | password123 |

### Key Development Commands
```bash
# Rails console
docker-compose exec web rails console

# Run tests
docker-compose exec web bundle exec rspec

# Database operations
docker-compose exec web rails db:migrate
docker-compose exec web rails db:seed

# Asset compilation
docker-compose exec web yarn build
```

## 🎯 Current Implementation Status

### ✅ Completed (Phase 1-3)
- **Foundation**: Rails 7 app with Docker, authentication, authorization
- **Core Features**: Projects, tasks, users, roles, admin dashboard
- **UI/UX Reuse**: OpenProject inline editing, Maybe Finance components
- **API Integration**: Real sync with OpenProject, Maybe, Nextcloud, Mapbox
- **Financial Management**: Budgets, transactions with Maybe-style UI
- **File Collaboration**: Nextcloud integration with WebDAV
- **Geospatial Features**: Interactive maps with Mapbox
- **Documentation**: Comprehensive guides and API references

### 🔄 In Progress (Phase 4)
- **Medusa E-commerce**: Product marketplace integration
- **Advanced Reporting**: Analytics dashboard with PDF export
- **User Onboarding**: Multi-step wizard and guided tours
- **Performance**: Caching optimization and production tuning

### 📋 Next Steps
1. **Medusa Integration**: Complete e-commerce API client and UI
2. **Reporting Dashboard**: Charts, PDF export, analytics
3. **Onboarding Flow**: User wizard with feature introduction
4. **Production Deployment**: Performance optimization, security audit
5. **CI/CD Pipeline**: GitHub Actions for testing and deployment

## 🔧 Environment Variables

### Required for Full Functionality
```bash
# External API Keys
OPENPROJECT_BASE_URL=https://your-openproject.com
OPENPROJECT_API_KEY=your_api_key

MAYBE_BASE_URL=https://your-maybe-instance.com
MAYBE_API_KEY=your_api_key

NEXTCLOUD_BASE_URL=https://your-nextcloud.com
NEXTCLOUD_USERNAME=your_username
NEXTCLOUD_PASSWORD=your_password

MAPBOX_ACCESS_TOKEN=your_mapbox_token

# Future integrations
MEDUSA_BASE_URL=https://your-medusa-instance.com
MEDUSA_API_KEY=your_api_key
```

## 🐛 Known Issues & Workarounds

### Rails Logger Compatibility
- **Issue**: concurrent-ruby >= 1.3.5 breaks Rails 7.0.8.7
- **Workaround**: `require 'logger'` in `config/boot.rb`
- **Status**: Resolved, documented in installation guide

### Port Conflicts
- **Issue**: Default Rails port 3000 conflicts with other services
- **Solution**: Using port 3001 in docker-compose.yml
- **Status**: Resolved

## 🎨 Design Patterns & Best Practices

### Authorization Pattern
```ruby
# All controllers use Pundit for authorization
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  
  def show
    @project = authorize Project.find(params[:id])
  end
end
```

### Service Object Pattern
```ruby
# All external API calls go through service objects
class ExternalApiService
  def self.sync_openproject_tasks(project)
    # Centralized API logic with error handling
  end
end
```

### UI Component Reuse
```erb
<!-- Reusable components with consistent styling -->
<%= render 'shared/inline_edit_field', 
    resource: @task, 
    field: :title, 
    input_type: 'text' %>

<%= render 'shared/maybe_budget_card', budget: @budget %>
```

## 📚 Key Documentation References

- **Installation**: `docs/installation.md` - Complete setup guide
- **Quick Start**: `docs/quick-start.md` - User onboarding
- **Project Management**: `docs/features/project-management.md`
- **Financial Features**: `docs/features/financial-management.md`
- **OpenProject Integration**: `docs/integrations/openproject.md`
- **Maybe Finance Integration**: `docs/integrations/maybe.md`

## 🤝 Collaboration Notes

### Code Style
- Follow Ruby community standards (RuboCop)
- Use Pundit for all authorization
- Service objects for external API calls
- Stimulus controllers for JavaScript functionality
- Tailwind CSS for styling consistency

### Git Workflow
- Feature branches for new development
- Comprehensive commit messages
- Pull requests with documentation updates
- Maintain changelog for major releases

---

**This context file enables seamless continuation of Lani platform development by any developer or AI assistant, providing complete technical and architectural context.**
