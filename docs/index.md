---
layout: default
title: "Lani Platform Documentation"
description: "Comprehensive project management and collaboration platform"
---

<div class="hero">
  <div class="hero-content">
    <img src="assets/images/lani-logo.png" alt="Lani Platform" class="hero-logo">
    <h1>Lani Platform</h1>
    <p class="hero-subtitle">Comprehensive project management and collaboration platform</p>
    <div class="hero-buttons">
      <a href="getting-started/" class="btn btn-primary">Get Started</a>
      <a href="https://github.com/your-org/lani" class="btn btn-secondary">View on GitHub</a>
    </div>
  </div>
</div>

## 🚀 What is Lani?

Lani is a modern, comprehensive project management and collaboration platform built with Ruby on Rails. It integrates multiple external services to provide a complete business solution for teams of all sizes.

### Key Features

<div class="feature-grid">
  <div class="feature-card">
    <div class="feature-icon">🎯</div>
    <h3>Project Management</h3>
    <p>Advanced project creation, task management, and team collaboration with real-time updates.</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💰</div>
    <h3>Financial Management</h3>
    <p>Budget tracking, transaction management, and financial reporting with Maybe Finance integration.</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🛒</div>
    <h3>E-commerce</h3>
    <p>Product catalog, shopping cart, and order management with Medusa headless commerce.</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">🔗</div>
    <h3>Integrations</h3>
    <p>OpenProject, Nextcloud, Mapbox, and Stripe integrations for comprehensive functionality.</p>
  </div>
</div>

## 🏃‍♂️ Quick Start

### Docker (Recommended)

```bash
# Clone the repository
git clone https://github.com/your-org/lani.git
cd lani

# Start with Docker Compose
docker-compose up -d

# Setup database
docker-compose exec web rails db:setup

# Visit http://localhost:3000
```

### Kubernetes Deployment

```bash
# Add Helm repository
helm repo add lani https://your-org.github.io/lani/
helm repo update

# Install Lani Platform
helm install lani lani/lani --namespace lani --create-namespace
```

## 📚 Documentation Sections

<div class="docs-grid">
  <a href="getting-started/" class="docs-card">
    <div class="docs-icon">🏁</div>
    <h3>Getting Started</h3>
    <p>Installation, setup, and first steps with Lani Platform</p>
  </a>
  
  <a href="configuration/" class="docs-card">
    <div class="docs-icon">⚙️</div>
    <h3>Configuration</h3>
    <p>Environment variables, settings, and customization options</p>
  </a>
  
  <a href="deployment/" class="docs-card">
    <div class="docs-icon">🚀</div>
    <h3>Deployment</h3>
    <p>Production deployment with Docker, Kubernetes, and Helm</p>
  </a>
  
  <a href="api/" class="docs-card">
    <div class="docs-icon">🔌</div>
    <h3>API Reference</h3>
    <p>Complete REST API documentation and examples</p>
  </a>
  
  <a href="integrations/" class="docs-card">
    <div class="docs-icon">🔗</div>
    <h3>Integrations</h3>
    <p>External service integrations and configuration guides</p>
  </a>
  
  <a href="contributing/" class="docs-card">
    <div class="docs-icon">🤝</div>
    <h3>Contributing</h3>
    <p>Development setup, testing, and contribution guidelines</p>
  </a>
</div>

## 🛠️ Technology Stack

### Backend
- **Ruby on Rails 7** - Web application framework
- **PostgreSQL** - Primary database
- **Redis** - Caching and session storage
- **Sidekiq** - Background job processing

### Frontend
- **Hotwire/Turbo** - Real-time UI updates
- **Stimulus** - JavaScript framework
- **Tailwind CSS** - Utility-first CSS
- **Chart.js** - Data visualization

### Integrations
- **OpenProject** - Project management
- **Maybe Finance** - Financial data
- **Nextcloud** - File collaboration
- **Mapbox** - Geospatial features
- **Medusa** - E-commerce platform
- **Stripe** - Payment processing

## 🏆 Why Choose Lani?

- **🔋 Batteries Included**: Complete solution with all essential features
- **🔗 Integration Ready**: Pre-built integrations with popular services
- **🚀 Production Ready**: Enterprise-grade security and performance
- **📱 Modern UI**: Responsive design with excellent UX
- **🧪 Well Tested**: Comprehensive test coverage with Cypress and Vitest
- **📖 Well Documented**: Complete documentation and guides
- **🤝 Community Driven**: Open source with active community

## 🆘 Need Help?

- 📖 [Browse Documentation](getting-started/)
- 🐛 [Report Issues](https://github.com/your-org/lani/issues)
- 💬 [Join Discussions](https://github.com/your-org/lani/discussions)
- 🔒 [Security Policy](https://github.com/your-org/lani/security)

---

<div class="footer-cta">
  <h2>Ready to get started?</h2>
  <p>Follow our quick start guide and have Lani running in minutes.</p>
  <a href="getting-started/" class="btn btn-primary btn-large">Get Started Now</a>
</div>
