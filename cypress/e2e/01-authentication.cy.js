// Authentication and user management E2E tests
describe('Authentication', () => {
  beforeEach(() => {
    cy.visit('/')
  })

  describe('User Sign In', () => {
    it('should redirect to sign in page when not authenticated', () => {
      cy.url().should('include', '/users/sign_in')
      cy.get('[data-cy=sign-in-form]').should('be.visible')
    })

    it('should sign in with valid credentials', () => {
      cy.login(Cypress.env('user_email'), Cypress.env('user_password'))
      cy.url().should('not.include', '/users/sign_in')
      cy.get('[data-cy=user-menu]').should('contain', 'Alice')
    })

    it('should show error with invalid credentials', () => {
      cy.visit('/users/sign_in')
      cy.get('[data-cy=email-input]').type('invalid@example.com')
      cy.get('[data-cy=password-input]').type('wrongpassword')
      cy.get('[data-cy=sign-in-button]').click()
      cy.get('[data-cy=error-message]').should('contain', 'Invalid')
    })

    it('should sign out successfully', () => {
      cy.loginAsUser()
      cy.logout()
      cy.url().should('include', '/users/sign_in')
    })
  })

  describe('User Registration', () => {
    it('should navigate to sign up page', () => {
      cy.visit('/users/sign_in')
      cy.get('[data-cy=sign-up-link]').click()
      cy.url().should('include', '/users/sign_up')
      cy.get('[data-cy=sign-up-form]').should('be.visible')
    })

    it('should validate required fields', () => {
      cy.visit('/users/sign_up')
      cy.get('[data-cy=sign-up-button]').click()
      cy.get('[data-cy=error-message]').should('be.visible')
    })
  })

  describe('Password Reset', () => {
    it('should navigate to forgot password page', () => {
      cy.visit('/users/sign_in')
      cy.get('[data-cy=forgot-password-link]').click()
      cy.url().should('include', '/users/password/new')
      cy.get('[data-cy=reset-password-form]').should('be.visible')
    })
  })

  describe('Role-based Access', () => {
    it('should show admin menu for admin users', () => {
      cy.loginAsAdmin()
      cy.get('[data-cy=admin-menu]').should('be.visible')
      cy.get('[data-cy=admin-menu]').click()
      cy.get('[data-cy=admin-dashboard-link]').should('be.visible')
    })

    it('should not show admin menu for regular users', () => {
      cy.loginAsUser()
      cy.get('[data-cy=admin-menu]').should('not.exist')
    })
  })
})
