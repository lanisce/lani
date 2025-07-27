// Cypress support file for E2E tests
import './commands'

// Hide fetch/XHR requests from command log
const app = window.top;
if (!app.document.head.querySelector('[data-hide-command-log-request]')) {
  const style = app.document.createElement('style')
  style.innerHTML = '.command-name-request, .command-name-xhr { display: none }'
  style.setAttribute('data-hide-command-log-request', '')
  app.document.head.appendChild(style)
}

// Global configuration
Cypress.on('uncaught:exception', (err, runnable) => {
  // Ignore certain errors that don't affect functionality
  if (err.message.includes('ResizeObserver loop limit exceeded')) {
    return false
  }
  if (err.message.includes('Non-Error promise rejection captured')) {
    return false
  }
  return true
})

// Set up test environment
beforeEach(() => {
  // Clear any existing sessions
  cy.clearCookies()
  cy.clearLocalStorage()
  
  // Set viewport
  cy.viewport(1280, 720)
})
