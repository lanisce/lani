---
layout: default
title: "Contributing"
description: "How to contribute to the Lani Platform"
---

# Contributing to Lani Platform

We welcome contributions from the community! This guide will help you get started with contributing to the Lani Platform.

## 🤝 Ways to Contribute

<div class="feature-grid">
  <div class="feature-card">
    <div class="feature-icon">🐛</div>
    <h3>Bug Reports</h3>
    <p>Help us identify and fix issues in the platform</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💡</div>
    <h3>Feature Requests</h3>
    <p>Suggest new features and improvements</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">💻</div>
    <h3>Code Contributions</h3>
    <p>Submit bug fixes, features, and improvements</p>
  </div>
  
  <div class="feature-card">
    <div class="feature-icon">📚</div>
    <h3>Documentation</h3>
    <p>Improve guides, tutorials, and API documentation</p>
  </div>
</div>

## 🚀 Getting Started

### 1. Fork the Repository

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/lani.git
cd lani

# Add upstream remote
git remote add upstream https://github.com/your-org/lani.git
```

### 2. Set Up Development Environment

```bash
# Install dependencies
bin/setup

# Start development server
bin/dev

# Run tests to ensure everything works
yarn test
bundle exec rspec
```

### 3. Create a Feature Branch

```bash
# Create and switch to a new branch
git checkout -b feature/amazing-feature

# Or for bug fixes
git checkout -b fix/bug-description
```

## 📋 Development Guidelines

### Code Standards

#### Ruby Code Style

We follow the [Ruby Style Guide](https://rubystyle.guide/) and use RuboCop for enforcement:

```bash
# Run RuboCop
bundle exec rubocop

# Auto-fix issues
bundle exec rubocop -a
```

**Key Ruby conventions:**
- Use 2 spaces for indentation
- Maximum line length of 120 characters
- Use snake_case for variables and methods
- Use PascalCase for classes and modules
- Add comprehensive comments for complex logic

#### JavaScript Code Style

We use ESLint with our custom configuration:

```bash
# Run ESLint
yarn lint:js

# Auto-fix issues
yarn lint:js --fix
```

**Key JavaScript conventions:**
- Use 2 spaces for indentation
- Use camelCase for variables and functions
- Use PascalCase for classes
- Use const/let instead of var
- Add JSDoc comments for functions

#### CSS/SCSS Style

We use Stylelint for CSS/SCSS:

```bash
# Run Stylelint
yarn lint:css

# Auto-fix issues
yarn lint:css --fix
```

### Testing Requirements

All contributions must include appropriate tests:

#### Ruby Tests (RSpec)

```ruby
# spec/models/project_spec.rb
RSpec.describe Project, type: :model do
  describe 'validations' do
    it 'requires a name' do
      project = build(:project, name: nil)
      expect(project).not_to be_valid
      expect(project.errors[:name]).to include("can't be blank")
    end
  end

  describe 'associations' do
    it 'has many tasks' do
      association = described_class.reflect_on_association(:tasks)
      expect(association.macro).to eq :has_many
    end
  end
end
```

#### JavaScript Tests (Vitest)

```javascript
// test/controllers/inline_edit_controller.test.js
import { describe, it, expect, beforeEach } from 'vitest'
import { InlineEditController } from '../app/javascript/controllers/inline_edit_controller'

describe('InlineEditController', () => {
  let controller

  beforeEach(() => {
    controller = new InlineEditController()
  })

  it('initializes with correct default values', () => {
    expect(controller.isEditingValue).toBe(false)
    expect(controller.originalValueValue).toBe('')
  })
})
```

#### End-to-End Tests (Cypress)

```javascript
// cypress/e2e/projects.cy.js
describe('Project Management', () => {
  beforeEach(() => {
    cy.login('admin@lani.local', 'password')
  })

  it('creates a new project', () => {
    cy.visit('/projects')
    cy.get('[data-cy=new-project-btn]').click()
    cy.get('[data-cy=project-name]').type('Test Project')
    cy.get('[data-cy=project-description]').type('Test Description')
    cy.get('[data-cy=submit-btn]').click()
    
    cy.url().should('include', '/projects/')
    cy.contains('Test Project').should('be.visible')
  })
})
```

### Commit Message Format

We follow [Conventional Commits](https://conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```bash
feat(projects): add project templates functionality

fix(auth): resolve login redirect issue

docs(api): update authentication documentation

test(tasks): add tests for task completion workflow
```

## 🔄 Pull Request Process

### 1. Prepare Your Changes

```bash
# Ensure your branch is up to date
git fetch upstream
git rebase upstream/main

# Run all tests
yarn test
bundle exec rspec
yarn cypress:run

# Run linters
bundle exec rubocop
yarn lint
```

### 2. Create Pull Request

1. **Push your branch**:
   ```bash
   git push origin feature/amazing-feature
   ```

2. **Create PR on GitHub**:
   - Use our PR template
   - Provide clear description
   - Link related issues
   - Add screenshots for UI changes

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Tests pass locally
   - [ ] Added new tests
   - [ ] Manual testing completed

   ## Screenshots (if applicable)
   [Add screenshots here]

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Self-review completed
   - [ ] Documentation updated
   - [ ] No breaking changes
   ```

### 3. Code Review Process

1. **Automated Checks**: CI/CD pipeline runs automatically
2. **Peer Review**: At least one maintainer reviews
3. **Feedback**: Address review comments
4. **Approval**: Maintainer approves changes
5. **Merge**: Squash and merge to main

## 🐛 Bug Reports

### Before Reporting

1. **Search existing issues**
2. **Check documentation**
3. **Test with latest version**
4. **Reproduce the issue**

### Bug Report Template

```markdown
**Bug Description**
Clear description of the bug

**Steps to Reproduce**
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

**Expected Behavior**
What you expected to happen

**Screenshots**
Add screenshots if applicable

**Environment**
- OS: [e.g. macOS 12.0]
- Browser: [e.g. Chrome 96]
- Lani Version: [e.g. 1.2.0]
- Docker: [Yes/No]

**Additional Context**
Any other relevant information
```

## 💡 Feature Requests

### Feature Request Template

```markdown
**Feature Description**
Clear description of the feature

**Problem Statement**
What problem does this solve?

**Proposed Solution**
How should this work?

**Alternatives Considered**
Other solutions you've considered

**Additional Context**
Mockups, examples, or references
```

## 📚 Documentation Contributions

### Types of Documentation

1. **User Guides**: Help users understand features
2. **API Documentation**: REST API reference
3. **Developer Docs**: Technical implementation details
4. **Tutorials**: Step-by-step learning materials

### Documentation Standards

- Use clear, concise language
- Include code examples
- Add screenshots for UI features
- Test all examples
- Follow markdown standards

### Local Documentation Development

```bash
# Install Jekyll (for GitHub Pages)
gem install jekyll bundler

# Serve documentation locally
cd docs
bundle install
bundle exec jekyll serve

# Visit http://localhost:4000
```

## 🏗️ Architecture Guidelines

### Service Objects

Use service objects for complex business logic:

```ruby
# app/services/project_creator_service.rb
class ProjectCreatorService
  def initialize(user, params)
    @user = user
    @params = params
  end

  def call
    ActiveRecord::Base.transaction do
      create_project
      setup_default_budget
      invite_team_members
      sync_with_external_apis
    end
  end

  private

  def create_project
    @project = @user.projects.create!(@params)
  end
end
```

### Controller Patterns

Keep controllers thin:

```ruby
class ProjectsController < ApplicationController
  def create
    result = ProjectCreatorService.new(current_user, project_params).call
    
    if result.success?
      redirect_to result.project, notice: 'Project created successfully'
    else
      render :new, alert: result.error
    end
  end
end
```

### Stimulus Controllers

Follow Stimulus conventions:

```javascript
// app/javascript/controllers/project_form_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["name", "description", "budget"]
  static values = { 
    minBudget: Number,
    maxBudget: Number 
  }

  connect() {
    this.validateForm()
  }

  validateForm() {
    // Validation logic
  }
}
```

## 🔒 Security Guidelines

### Security Best Practices

1. **Input Validation**: Validate all user inputs
2. **SQL Injection**: Use parameterized queries
3. **XSS Prevention**: Sanitize output
4. **CSRF Protection**: Use Rails CSRF tokens
5. **Authentication**: Secure session management
6. **Authorization**: Proper access controls

### Reporting Security Issues

**Do not create public issues for security vulnerabilities.**

Email security issues to: [security@lani.yourdomain.com](mailto:security@lani.yourdomain.com)

Include:
- Description of the vulnerability
- Steps to reproduce
- Potential impact
- Suggested fix (if any)

## 🎯 Performance Guidelines

### Database Optimization

```ruby
# Use includes to avoid N+1 queries
projects = Project.includes(:tasks, :users).where(status: 'active')

# Use counter caches for counts
class Project < ApplicationRecord
  has_many :tasks, counter_cache: true
end

# Add database indexes
add_index :tasks, [:project_id, :status]
```

### Caching Strategies

```ruby
# Fragment caching
<% cache project do %>
  <%= render project %>
<% end %>

# Service-level caching
class ProjectService
  def expensive_calculation(project)
    Rails.cache.fetch("project_#{project.id}_calculation", expires_in: 1.hour) do
      # Expensive operation
    end
  end
end
```

## 🌍 Internationalization

### Adding Translations

```yaml
# config/locales/en.yml
en:
  projects:
    new:
      title: "Create New Project"
      description: "Fill in the details below"
    form:
      name: "Project Name"
      budget: "Budget"
```

### Using Translations

```erb
<%= t('projects.new.title') %>
<%= t('projects.form.name') %>
```

## 📊 Monitoring and Logging

### Logging Best Practices

```ruby
# Use structured logging
Rails.logger.info "Project created", 
  project_id: project.id,
  user_id: current_user.id,
  timestamp: Time.current

# Log errors with context
Rails.logger.error "External API failed",
  service: 'openproject',
  error: e.message,
  project_id: project.id
```

## 🎉 Recognition

### Contributors

We recognize contributors in several ways:

1. **GitHub Contributors**: Automatic recognition
2. **Release Notes**: Major contributions mentioned
3. **Hall of Fame**: Top contributors featured
4. **Swag**: Stickers and swag for regular contributors

### Maintainer Path

Regular contributors can become maintainers:

1. **Consistent Contributions**: Regular, quality contributions
2. **Community Involvement**: Help other contributors
3. **Code Review**: Participate in code reviews
4. **Nomination**: Current maintainer nomination
5. **Voting**: Maintainer team vote

## 📞 Getting Help

### Community Channels

- **GitHub Discussions**: [General discussions](https://github.com/your-org/lani/discussions)
- **Discord**: [Join our Discord](https://discord.gg/lani-platform)
- **Stack Overflow**: Tag questions with `lani-platform`

### Maintainer Contact

- **General Questions**: [GitHub Discussions](https://github.com/your-org/lani/discussions)
- **Security Issues**: [security@lani.yourdomain.com](mailto:security@lani.yourdomain.com)
- **Maintainer Team**: [maintainers@lani.yourdomain.com](mailto:maintainers@lani.yourdomain.com)

---

<div class="footer-cta">
  <h2>Ready to contribute?</h2>
  <p>Join our community of contributors and help make Lani Platform even better!</p>
  <a href="https://github.com/your-org/lani/fork" class="btn btn-primary">Fork Repository</a>
</div>
