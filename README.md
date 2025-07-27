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

```

## 📖 Documentation

<table>
  <tr>
    <td width="33%">
      <h3>🏁 Getting Started</h3>
      <ul>
        <li><a href="docs/installation.md">Installation Guide</a></li>
        <li><a href="docs/configuration.md">Configuration</a></li>
        <li><a href="docs/development.md">Development Setup</a></li>
      </ul>
    </td>
    <td width="33%">
      <h3>🚀 Deployment</h3>
      <ul>
        <li><a href="docs/deployment/production-deployment.md">Production Deployment</a></li>
        <li><a href="docs/deployment/kubernetes.md">Kubernetes Guide</a></li>
        <li><a href="docs/deployment/helm-chart-publishing.md">Helm Chart</a></li>
      </ul>
    </td>
    <td width="33%">
      <h3>🔧 Advanced</h3>
      <ul>
        <li><a href="docs/api/README.md">API Documentation</a></li>
        <li><a href="docs/integrations/README.md">Integrations</a></li>
        <li><a href="docs/development/testing.md">Testing Guide</a></li>
      </ul>
    </td>
  </tr>
</table>

## 🤝 Contributing

We ❤️ contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### 🌟 Contributors

<a href="https://github.com/your-org/lani/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=your-org/lani" />
</a>

### 🐛 Bug Reports & Feature Requests

- 🐛 [Report a Bug](https://github.com/your-org/lani/issues/new?template=bug_report.md)
- 💡 [Request a Feature](https://github.com/your-org/lani/issues/new?template=feature_request.md)
- 💬 [Join Discussion](https://github.com/your-org/lani/discussions)

## 📊 Project Stats

<div align="center">
  <img src="https://github-readme-stats.vercel.app/api?username=lanisce&repo=lani&show_icons=true&theme=default" alt="GitHub Stats">
  <img src="https://github-readme-stats.vercel.app/api/top-langs/?username=lanisce&repo=lani&layout=compact" alt="Languages">
</div>

## 🏆 Achievements

- [ ] 🌟 **1000+ Stars** on GitHub
- [ ] 🚀 **Production Ready** with enterprise features
- [ ] 🔒 **Security First** with automated scanning
- [ ] 📈 **High Performance** with optimized caching
- [ ] 🌍 **Multi-language** support ready
- [ ] ♿ **Accessibility** WCAG 2.1 AA compliant

## 📄 License

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for details.

### 🙏 Third-Party Acknowledgments

This project incorporates components from several open source projects. See [LICENSES.md](LICENSES.md) for detailed attribution.

## 🆘 Support

<table>
  <tr>
    <td width="25%" align="center">
      <a href="docs/">
        <img src="https://img.icons8.com/color/48/000000/book.png" width="32">
        <br><strong>Documentation</strong>
      </a>
    </td>
    <td width="25%" align="center">
      <a href="https://github.com/your-org/lani/issues">
        <img src="https://img.icons8.com/color/48/000000/bug.png" width="32">
        <br><strong>Issues</strong>
      </a>
    </td>
    <td width="25%" align="center">
      <a href="https://github.com/your-org/lani/discussions">
        <img src="https://img.icons8.com/color/48/000000/chat.png" width="32">
        <br><strong>Discussions</strong>
      </a>
    </td>
    <td width="25%" align="center">
      <a href="SECURITY.md">
        <img src="https://img.icons8.com/color/48/000000/security-checked.png" width="32">
        <br><strong>Security</strong>
      </a>
    </td>
  </tr>
</table>


## 📞 Support

For questions, issues, or contributions:

- 🐛 [Create an issue](https://github.com/your-org/lani/issues) on GitHub
- 📖 Check the [comprehensive documentation](docs/)
- 💬 Join our community discussions
- 📧 Contact the maintainers

---

**Built with ❤️ by the Lani Platform team**

*Transforming project management through direct UI/UX reuse and seamless API integration.*
