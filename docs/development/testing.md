# Testing Guide

## Overview

Lani includes comprehensive automated testing to ensure reliability, maintainability, and quality across all platform features. Our testing strategy combines end-to-end (E2E) testing with Cypress and unit/integration testing with Vitest.

## Test Architecture

### End-to-End Testing (Cypress)

Cypress tests simulate real user interactions and validate complete workflows across the entire application stack.

**Test Coverage:**
- Authentication and user management
- Project management (CRUD, status, location, team)
- Task management (CRUD, inline editing, filtering, bulk actions)
- Financial management (budgets, transactions, Maybe integration)
- E-commerce integration (Medusa products, cart, checkout)
- User onboarding wizard (7-step guided flow)
- Reporting and analytics dashboard
- Accessibility compliance

**Key Features:**
- Custom commands for reusable operations
- Real browser testing (Chrome, Firefox)
- Video recording and screenshot capture
- Network request stubbing and mocking
- Accessibility testing with cypress-axe

### Unit/Integration Testing (Vitest)

Vitest tests focus on individual components, services, and utility functions in isolation.

**Test Coverage:**
- Stimulus controllers (Mapbox, Inline Edit)
- External API service integrations
- Utility functions and helpers
- Error handling and edge cases
- Data transformation and validation

**Key Features:**
- Fast execution with jsdom environment
- Comprehensive mocking capabilities
- Coverage reporting with v8
- Hot module reloading during development

## Running Tests

### Unit Tests (Vitest)

```bash
# Interactive testing with watch mode
npm run test

# Single test run
npm run test:run

# Run with coverage report
npm run test:coverage

# Run specific test file
npm run test -- test/javascript/controllers/mapbox_controller.test.js

# Run tests matching pattern
npm run test -- --grep "should handle map initialization"
```

### End-to-End Tests (Cypress)

```bash
# Interactive mode with Cypress UI
npm run cypress:open

# Headless mode for CI/CD
npm run cypress:run

# Run specific test file
npm run cypress:run -- --spec "cypress/e2e/01-authentication.cy.js"

# Run with specific browser
npm run cypress:run -- --browser firefox
```

### Complete Test Suite

```bash
# Run all tests (unit + E2E)
npm run test:all

# CI-optimized test run
npm run test:ci
```

## Test Structure

### Cypress E2E Tests

Located in `cypress/e2e/`, organized by feature area:

- `01-authentication.cy.js` - User authentication flows
- `02-project-management.cy.js` - Project CRUD operations
- `03-task-management.cy.js` - Task management features
- `04-financial-management.cy.js` - Budget and transaction handling
- `05-ecommerce.cy.js` - Medusa integration testing
- `06-onboarding.cy.js` - User onboarding wizard
- `07-reporting-analytics.cy.js` - Dashboard and reporting

### Vitest Unit Tests

Located in `test/javascript/`, mirroring the application structure:

- `controllers/` - Stimulus controller tests
- `services/` - External API service tests
- `utils/` - Utility function tests

## Custom Commands

### Cypress Commands

Located in `cypress/support/commands.js`:

```javascript
// Authentication
cy.loginAsAdmin()
cy.loginAsProjectManager()
cy.loginAsUser()

// Project operations
cy.createProject(projectData)
cy.deleteProject(projectId)

// E-commerce
cy.addToCart(productId, quantity)
cy.completeCheckout(orderData)

// Onboarding
cy.completeOnboardingStep(stepNumber)
```

## Test Configuration

### Cypress Configuration

```javascript
// cypress.config.js
export default defineConfig({
  e2e: {
    baseUrl: 'http://localhost:3000',
    viewportWidth: 1280,
    viewportHeight: 720,
    video: true,
    screenshotOnRunFailure: true
  }
})
```

### Vitest Configuration

```javascript
// vitest.config.js
export default defineConfig({
  test: {
    environment: 'jsdom',
    setupFiles: ['./test/setup.js'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html', 'lcov']
    }
  }
})
```

## Mocking and Stubbing

### External API Mocking

Tests include comprehensive mocking for external services:

- OpenProject API
- Maybe Finance API
- Nextcloud WebDAV API
- Medusa e-commerce API
- Mapbox API

### Browser API Mocking

Global mocks for browser APIs in test environment:

```javascript
// test/setup.js
global.fetch = vi.fn()
global.localStorage = {
  getItem: vi.fn(),
  setItem: vi.fn(),
  removeItem: vi.fn()
}
```

## Accessibility Testing

Accessibility testing is integrated throughout the test suite:

```javascript
// Example accessibility test
it('should be accessible', () => {
  cy.visit('/projects')
  cy.injectAxe()
  cy.checkA11y()
})
```

## Performance Testing

Performance validation is included in E2E tests:

```javascript
// Example performance test
it('should load dashboard quickly', () => {
  cy.visit('/dashboard')
  cy.get('[data-testid="dashboard-content"]', { timeout: 2000 })
    .should('be.visible')
})
```

## Test Data Management

### Test Users

Predefined test accounts for different roles:

- Admin: `admin@lani.dev`
- Project Manager: `pm@lani.dev`
- Member: `alice@lani.dev`
- Viewer: `viewer@lani.dev`

### Test Data Cleanup

Tests include proper cleanup to maintain isolation:

```javascript
afterEach(() => {
  // Clean up test data
  cy.task('db:clean')
})
```

## Continuous Integration

Tests are designed to run in CI/CD environments:

```yaml
# Example GitHub Actions workflow
- name: Run Tests
  run: |
    npm run test:ci
    npm run cypress:run
```

## Debugging Tests

### Cypress Debugging

- Use `cy.debug()` to pause execution
- Enable video recording for failed tests
- Use browser developer tools in interactive mode

### Vitest Debugging

- Use `console.log()` for debugging output
- Run specific tests with `--reporter=verbose`
- Use VS Code debugger integration

## Best Practices

### Test Organization

- Group related tests in describe blocks
- Use descriptive test names
- Follow AAA pattern (Arrange, Act, Assert)

### Test Reliability

- Avoid hard-coded timeouts
- Use proper selectors (data-testid preferred)
- Clean up after each test
- Mock external dependencies

### Performance

- Run unit tests frequently during development
- Use E2E tests for critical user paths
- Parallelize test execution in CI

## Coverage Reports

Coverage reports are generated automatically:

```bash
# Generate coverage report
npm run test:coverage

# View HTML coverage report
open coverage/index.html
```

## Troubleshooting

### Common Issues

1. **Tests failing in CI but passing locally**
   - Check for timing issues
   - Verify environment variables
   - Review browser differences

2. **Flaky tests**
   - Add proper waits and assertions
   - Check for race conditions
   - Review test isolation

3. **Slow test execution**
   - Optimize test setup/teardown
   - Use appropriate test granularity
   - Consider parallel execution

### Getting Help

- Check test logs and screenshots
- Review Cypress documentation
- Consult Vitest documentation
- Check project-specific test patterns

## Contributing

When adding new features:

1. Write tests first (TDD approach)
2. Ensure adequate coverage
3. Follow existing test patterns
4. Update documentation as needed
5. Run full test suite before submitting

## Resources

- [Cypress Documentation](https://docs.cypress.io/)
- [Vitest Documentation](https://vitest.dev/)
- [Testing Library](https://testing-library.com/)
- [Accessibility Testing Guide](https://www.deque.com/axe/)
