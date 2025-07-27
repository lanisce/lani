// Custom Cypress commands for Lani platform testing

// Authentication commands
Cypress.Commands.add('login', (email, password) => {
  cy.visit('/users/sign_in')
  cy.get('[data-cy=email-input]').type(email)
  cy.get('[data-cy=password-input]').type(password)
  cy.get('[data-cy=sign-in-button]').click()
  cy.url().should('not.include', '/users/sign_in')
})

Cypress.Commands.add('loginAsAdmin', () => {
  cy.login(Cypress.env('admin_email'), Cypress.env('admin_password'))
})

Cypress.Commands.add('loginAsUser', () => {
  cy.login(Cypress.env('user_email'), Cypress.env('user_password'))
})

Cypress.Commands.add('loginAsPM', () => {
  cy.login(Cypress.env('pm_email'), Cypress.env('pm_password'))
})

Cypress.Commands.add('logout', () => {
  cy.get('[data-cy=user-menu]').click()
  cy.get('[data-cy=logout-link]').click()
  cy.url().should('include', '/users/sign_in')
})

// Project management commands
Cypress.Commands.add('createProject', (projectData) => {
  cy.visit('/projects/new')
  cy.get('[data-cy=project-name-input]').type(projectData.name)
  if (projectData.description) {
    cy.get('[data-cy=project-description-input]').type(projectData.description)
  }
  if (projectData.status) {
    cy.get('[data-cy=project-status-select]').select(projectData.status)
  }
  cy.get('[data-cy=create-project-button]').click()
  cy.url().should('include', '/projects/')
})

Cypress.Commands.add('createTask', (taskData) => {
  cy.get('[data-cy=new-task-button]').click()
  cy.get('[data-cy=task-title-input]').type(taskData.title)
  if (taskData.description) {
    cy.get('[data-cy=task-description-input]').type(taskData.description)
  }
  if (taskData.priority) {
    cy.get('[data-cy=task-priority-select]').select(taskData.priority)
  }
  if (taskData.due_date) {
    cy.get('[data-cy=task-due-date-input]').type(taskData.due_date)
  }
  cy.get('[data-cy=create-task-button]').click()
})

// Budget and financial commands
Cypress.Commands.add('createBudget', (budgetData) => {
  cy.get('[data-cy=new-budget-button]').click()
  cy.get('[data-cy=budget-name-input]').type(budgetData.name)
  cy.get('[data-cy=budget-amount-input]').type(budgetData.amount.toString())
  cy.get('[data-cy=budget-category-select]').select(budgetData.category)
  if (budgetData.start_date) {
    cy.get('[data-cy=budget-start-date-input]').type(budgetData.start_date)
  }
  if (budgetData.end_date) {
    cy.get('[data-cy=budget-end-date-input]').type(budgetData.end_date)
  }
  cy.get('[data-cy=create-budget-button]').click()
})

Cypress.Commands.add('addTransaction', (transactionData) => {
  cy.get('[data-cy=new-transaction-button]').click()
  cy.get('[data-cy=transaction-description-input]').type(transactionData.description)
  cy.get('[data-cy=transaction-amount-input]').type(transactionData.amount.toString())
  cy.get('[data-cy=transaction-type-select]').select(transactionData.transaction_type)
  cy.get('[data-cy=transaction-category-select]').select(transactionData.category)
  cy.get('[data-cy=create-transaction-button]').click()
})

// E-commerce commands
Cypress.Commands.add('addToCart', (productId, quantity = 1) => {
  cy.visit(`/products/${productId}`)
  if (quantity > 1) {
    cy.get('[data-cy=quantity-input]').clear().type(quantity.toString())
  }
  cy.get('[data-cy=add-to-cart-button]').click()
  cy.get('[data-cy=cart-notification]').should('be.visible')
})

Cypress.Commands.add('viewCart', () => {
  cy.get('[data-cy=cart-link]').click()
  cy.url().should('include', '/cart')
})

// Onboarding commands
Cypress.Commands.add('startOnboarding', () => {
  cy.visit('/onboarding/start')
  cy.url().should('include', '/onboarding/welcome')
})

Cypress.Commands.add('completeOnboardingStep', (stepData) => {
  if (stepData) {
    Object.keys(stepData).forEach(key => {
      cy.get(`[data-cy=${key}-input]`).type(stepData[key])
    })
  }
  cy.get('[data-cy=next-step-button]').click()
})

Cypress.Commands.add('skipOnboarding', () => {
  cy.get('[data-cy=skip-onboarding-link]').click()
  cy.get('[data-cy=confirm-skip-button]').click()
})

// Utility commands
Cypress.Commands.add('waitForTurbo', () => {
  cy.window().its('Turbo').should('exist')
})

Cypress.Commands.add('interceptApiCall', (method, url, alias) => {
  cy.intercept(method, url).as(alias)
})

Cypress.Commands.add('checkAccessibility', () => {
  cy.injectAxe()
  cy.checkA11y()
})

// File upload command
Cypress.Commands.add('uploadFile', (selector, fileName, fileType = 'text/plain') => {
  cy.get(selector).selectFile({
    contents: Cypress.Buffer.from('file contents'),
    fileName: fileName,
    mimeType: fileType,
  })
})

// Wait for charts to load
Cypress.Commands.add('waitForCharts', () => {
  cy.get('[data-cy=chart-container]').should('be.visible')
  cy.wait(1000) // Allow time for Chart.js to render
})
