# Lani Platform

> **A unified project management platform that directly reuses UI/UX patterns and integrates APIs from OpenProject, Maybe Finance, Nextcloud, and Medusa for seamless project management, financial tracking, and team collaboration.**

[![Ruby on Rails](https://img.shields.io/badge/Ruby%20on%20Rails-7.0+-red.svg)](https://rubyonrails.org/)
[![Docker](https://img.shields.io/badge/Docker-Ready-blue.svg)](https://www.docker.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Documentation](https://img.shields.io/badge/Docs-Comprehensive-brightgreen.svg)](docs/)

## 🎯 Vision

Lani transforms project management by **directly reusing** the best UI/UX patterns from industry-leading platforms while providing **real API integration** for seamless data synchronization:

- 🎨 **OpenProject UI/UX**: Inline editing, task management, and familiar workflows
- 💰 **Maybe Finance Components**: Beautiful budget cards, transaction rows, and financial dashboards
- 🔄 **Real API Integration**: Bidirectional sync with OpenProject, Maybe, Nextcloud, and more
- 🚀 **Unified Experience**: One platform for projects, finances, files, and team collaboration

## ✨ Key Features

### 🎨 Direct UI/UX Reuse

- **OpenProject-style inline editing** with click-to-edit functionality and keyboard shortcuts
- **Maybe Finance budget cards** with progress bars, color-coded status, and quick actions
- **Maybe-style transaction rows** with category icons, amount styling, and elegant layouts
- **Consistent design patterns** across all integrated services for familiar user experience

### 🔌 Real API Integration

- **OpenProject API v3**: Bidirectional project and work package synchronization
- **Maybe Finance API**: Budget and transaction data sync with intelligent mapping
- **Nextcloud WebDAV**: File sharing and collaboration with team members
- **Mapbox API**: Interactive maps for geospatial project features

### 🚀 Core Platform Features

- **Project Management**: Tasks, teams, timelines with OpenProject-inspired interface
- **Financial Management**: Budgets, transactions, reporting with Maybe Finance UI
- **File Collaboration**: Document sharing and team collaboration via Nextcloud
- **User Management**: Role-based permissions and team organization
- **Admin Dashboard**: System analytics, user management, and configuration
- **Geospatial Features**: Interactive project maps and location-based planning

### 🛠️ Technical Excellence

- **Ruby on Rails 7** with Hotwire for reactive, modern web applications
- **Stimulus Controllers** replicating OpenProject's inline editing behavior
- **Tailwind CSS** with exact color matching to OpenProject and Maybe designs
- **Docker Containerization** for consistent development and deployment
- **Comprehensive Testing** with RSpec and feature tests
- **Background Processing** with Sidekiq for API synchronization and system statistics

## 🚀 Quick Start

### Prerequisites

- Docker and Docker Compose
- Ruby 3.1.4
- Node.js 18+
- Yarn package manager

### Setup

```bash
# Clone the repository
git clone <repository-url>
cd lani

# Install dependencies
yarn install

# Run setup script
./bin/setup

# Start development environment
./bin/dev
```

The application will be available at `http://localhost:3000`.

### Testing

Lani includes comprehensive test coverage with both unit and end-to-end testing:

```bash
# Unit tests with Vitest
npm run test              # Interactive testing
npm run test:run          # Run once
npm run test:coverage     # With coverage report

# End-to-end tests with Cypress
npm run cypress:open      # Interactive E2E testing
npm run cypress:run       # Headless E2E testing

# Run all tests
npm run test:all          # Both unit and E2E tests
npm run test:ci           # CI-optimized test suite
```

### Access the Platform

- **Web Interface**: http://localhost:3001
- **Admin Dashboard**: http://localhost:3001/admin
- **API Documentation**: http://localhost:3001/api/v1

### Default Login Accounts

| Role | Email | Password |
|------|-------|---------|
| Admin | admin@lani.dev | password123 |
| Project Manager | pm@lani.dev | password123 |
| Team Member | alice@lani.dev | password123 |
| Viewer | viewer@lani.dev | password123 |

## 📚 Documentation

### Getting Started

- [📖 Installation Guide](docs/installation.md) - Complete setup instructions
- [⚡ Quick Start](docs/quick-start.md) - Get up and running in minutes
- [⚙️ Configuration](docs/configuration.md) - Environment and API setup

### Core Features

- [📋 Project Management](docs/features/project-management.md) - OpenProject-style task management
- [💰 Financial Management](docs/features/financial-management.md) - Maybe Finance-inspired budgeting
- [📁 File Management](docs/features/file-management.md) - Nextcloud collaboration
- [👥 User Management](docs/features/user-management.md) - Roles and permissions

### Integrations

- [🎨 OpenProject Integration](docs/integrations/openproject.md) - UI reuse and API sync
- [💳 Maybe Finance Integration](docs/integrations/maybe.md) - Financial data sync
- [☁️ Nextcloud Integration](docs/integrations/nextcloud.md) - File collaboration
- [🗺️ Mapbox Integration](docs/integrations/mapbox.md) - Geospatial features

### Development

- [🏗️ Architecture Overview](docs/development/architecture.md) - System design
- [🔌 API Reference](docs/development/api-reference.md) - Complete API docs
- [🧪 Testing Guide](docs/development/testing.md) - Comprehensive test coverage

### Quality Assurance

Lani includes comprehensive automated testing to ensure reliability and maintainability:

#### Test Coverage
- **End-to-End Tests (Cypress)**: Complete user workflow testing
  - Authentication and authorization flows
  - Project and task management operations
  - Financial management and reporting
  - E-commerce integration (Medusa)
  - User onboarding wizard
  - Accessibility compliance testing

- **Unit/Integration Tests (Vitest)**: Component and service testing
  - Stimulus controllers (Mapbox, Inline Edit)
  - External API service integrations
  - Utility functions and helpers
  - Error handling and edge cases

#### Test Commands
```bash
# Unit Tests
npm run test              # Interactive mode
npm run test:run          # Single run
npm run test:coverage     # With coverage report

# E2E Tests  
npm run cypress:open      # Interactive mode
npm run cypress:run       # Headless mode

# All Tests
npm run test:all          # Complete test suite
npm run test:ci           # CI-optimized
```

#### Test Features
- Custom Cypress commands for common operations
- Comprehensive mocking for external APIs
- Accessibility testing with cypress-axe
- Cross-browser compatibility testing
- Performance and loading state validation
- Video recording and screenshot capture for debugging
- [🎨 UI Components](docs/development/ui-components.md) - Reusable components
- [🗃️ Database Schema](docs/development/database-schema.md) - Data models

## 🎯 Implementation Status

### ✅ Completed Features

**Foundation & Core Platform**

- [x] Ruby on Rails 7 application with Docker setup
- [x] Database foundation (PostgreSQL, Redis, Sidekiq)
- [x] User authentication (Devise) and authorization (Pundit)
- [x] Core models: User, Project, ProjectMembership, Task
- [x] Full CRUD operations with role-based access control
- [x] Modern UI with Tailwind CSS and responsive design

**Direct UI/UX Reuse**

- [x] OpenProject-style inline editing with Stimulus controllers
- [x] Maybe Finance budget cards with progress visualization
- [x] Maybe-style transaction rows with elegant layouts
- [x] Consistent design patterns across integrated services

**Real API Integration**

- [x] OpenProject API v3 client with bidirectional sync
- [x] Maybe Finance API integration for financial data
- [x] Nextcloud WebDAV for file collaboration
- [x] Mapbox integration for interactive project maps
- [x] ExternalApiService with comprehensive error handling

**Advanced Features**

- [x] Project management with OpenProject-inspired interface
- [x] Financial management with Maybe Finance UI components
- [x] File sharing and collaboration via Nextcloud
- [x] Geospatial features with interactive maps
- [x] Admin dashboard with user management and analytics
- [x] Background job processing for API synchronization
- [x] E-commerce marketplace with Medusa integration

**E-commerce Integration (Medusa)**

- [x] Complete product catalog with search and filtering
- [x] Shopping cart with real-time updates via Turbo Streams
- [x] Order management and checkout processing
- [x] Admin product synchronization from Medusa API
- [x] Multi-variant product support with inventory tracking
- [x] Responsive storefront with modern UI design

**Reporting & Analytics**

- [x] Advanced reporting and analytics dashboard
- [x] Multi-level project reports with charts and visualizations
- [x] PDF export functionality for detailed reports
- [x] Real-time metrics and activity feeds
- [x] Interactive charts using Chart.js

**User Experience**

- [x] User onboarding wizard and guided tours
- [x] 7-step progressive onboarding flow
- [x] Integration status checking and setup guidance
- [x] Sample project and task creation during onboarding

**Performance & Payments**

- [x] Performance optimization and caching
- [x] Comprehensive Redis-based caching with CacheService
- [x] Controller performance monitoring and optimization
- [x] Production-ready environment configuration
- [x] Payment processing integration (Stripe)
- [x] Subscription management and billing
- [x] Secure webhook handling and payment confirmation
- [x] Customer portal and payment method management

### 🔄 Final Tasks

- [ ] Production deployment and CI/CD pipeline
- [ ] Security audit and penetration testing
- [ ] Load testing and performance benchmarking
- [ ] Documentation finalization and deployment guides

## 🛠️ Technology Stack

### Backend

- **Ruby on Rails 7** - Modern web application framework
- **PostgreSQL** - Primary database for application data
- **Redis** - Caching and background job queue
- **Sidekiq** - Background job processing
- **Pundit** - Authorization and access control
- **Devise** - User authentication

### Frontend

- **Hotwire** - Reactive web applications without JavaScript frameworks
- **Stimulus** - JavaScript framework for progressive enhancement
- **Tailwind CSS** - Utility-first CSS framework
- **Importmap** - Modern JavaScript module management

### External Integrations

- **OpenProject API v3** - Project and work package management
- **Maybe Finance API** - Budget and transaction synchronization
- **Nextcloud WebDAV** - File sharing and collaboration
- **Mapbox API** - Interactive maps and geospatial features
- **Medusa API** - E-commerce platform for product marketplace

### Infrastructure

- **Docker** - Containerized development and deployment
- **Docker Compose** - Multi-container application orchestration
- **GitHub Actions** - Continuous integration and deployment

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Submit a pull request

### Code Style

- Follow Ruby community standards (RuboCop)
- Write comprehensive tests (RSpec)
- Document new features and APIs
- Maintain consistent UI/UX patterns

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

### Inspiration and UI/UX Reuse

- **[OpenProject](https://github.com/opf/openproject)** - Inline editing patterns and task management UI
- **[Maybe Finance](https://github.com/maybe-finance/maybe)** - Budget cards and financial interface design
- **[Nextcloud](https://github.com/nextcloud)** - File collaboration and sharing patterns
- **[Medusa](https://github.com/medusajs/medusa)** - E-commerce integration architecture

### Technology Partners

- **[Mapbox](https://www.mapbox.com/)** - Interactive maps and geospatial features
- **[Tailwind CSS](https://tailwindcss.com/)** - Utility-first CSS framework
- **[Ruby on Rails](https://rubyonrails.org/)** - Web application framework

## 📞 Support

For questions, issues, or contributions:

- 🐛 [Create an issue](https://github.com/your-org/lani/issues) on GitHub
- 📖 Check the [comprehensive documentation](docs/)
- 💬 Join our community discussions
- 📧 Contact the maintainers

---

**Built with ❤️ by the Lani Platform team**

*Transforming project management through direct UI/UX reuse and seamless API integration.*
