// User onboarding wizard E2E tests
describe('User Onboarding', () => {
  beforeEach(() => {
    // Create a fresh user for onboarding tests
    cy.visit('/users/sign_up')
    cy.get('[data-cy=name-input]').type('New User')
    cy.get('[data-cy=email-input]').type(`newuser${Date.now()}@example.com`)
    cy.get('[data-cy=password-input]').type('password123')
    cy.get('[data-cy=password-confirmation-input]').type('password123')
    cy.get('[data-cy=sign-up-button]').click()
  })

  describe('Onboarding Flow', () => {
    it('should start onboarding for new users', () => {
      cy.url().should('include', '/onboarding/welcome')
      cy.get('[data-cy=onboarding-welcome]').should('be.visible')
      cy.get('[data-cy=progress-bar]').should('be.visible')
      cy.get('[data-cy=step-indicator]').should('contain', 'Step 1 of 7')
    })

    it('should navigate through welcome step', () => {
      cy.get('[data-cy=welcome-content]').should('be.visible')
      cy.get('[data-cy=platform-features]').should('be.visible')
      cy.get('[data-cy=time-estimate]').should('contain', '5 minutes')
      cy.get('[data-cy=next-step-button]').click()
      cy.url().should('include', '/onboarding/profile_setup')
    })

    it('should complete profile setup step', () => {
      cy.get('[data-cy=next-step-button]').click() // Go to profile setup
      
      cy.get('[data-cy=profile-setup-form]').should('be.visible')
      cy.get('[data-cy=bio-input]').type('I am a project manager passionate about efficient workflows.')
      cy.get('[data-cy=timezone-select]').select('America/New_York')
      cy.get('[data-cy=notification-preferences]').check(['email_updates', 'task_reminders'])
      
      cy.completeOnboardingStep()
      cy.url().should('include', '/onboarding/first_project')
    })

    it('should create first project during onboarding', () => {
      // Navigate to first project step
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      
      cy.get('[data-cy=first-project-form]').should('be.visible')
      cy.get('[data-cy=project-name-input]').type('My First Onboarding Project')
      cy.get('[data-cy=project-description-input]').type('A project created during the onboarding process')
      cy.get('[data-cy=project-status-select]').select('active')
      
      cy.completeOnboardingStep()
      cy.url().should('include', '/onboarding/team_invitation')
    })

    it('should handle team invitations step', () => {
      // Navigate to team invitation step
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      cy.completeOnboardingStep({
        project_name: 'Test Project',
        project_description: 'Test Description'
      }) // first project
      
      cy.get('[data-cy=team-invitation-form]').should('be.visible')
      cy.get('[data-cy=invitation-emails-input]').type('colleague1@example.com, colleague2@example.com')
      cy.get('[data-cy=invitation-message-textarea]').type('Join me on this exciting project!')
      
      cy.completeOnboardingStep()
      cy.url().should('include', '/onboarding/integrations')
    })

    it('should show available integrations', () => {
      // Navigate to integrations step
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      cy.completeOnboardingStep({
        project_name: 'Test Project',
        project_description: 'Test Description'
      }) // first project
      cy.completeOnboardingStep() // team invitation
      
      cy.get('[data-cy=integrations-list]').should('be.visible')
      cy.get('[data-cy=integration-card]').should('have.length', 4)
      
      // Check integration cards
      cy.get('[data-cy=openproject-integration]').should('be.visible')
      cy.get('[data-cy=maybe-integration]').should('be.visible')
      cy.get('[data-cy=nextcloud-integration]').should('be.visible')
      cy.get('[data-cy=mapbox-integration]').should('be.visible')
      
      cy.get('[data-cy=openproject-integration]').click()
      cy.get('[data-cy=maybe-integration]').click()
      
      cy.completeOnboardingStep()
      cy.url().should('include', '/onboarding/features_tour')
    })

    it('should display features tour', () => {
      // Navigate to features tour step
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      cy.completeOnboardingStep({
        project_name: 'Test Project',
        project_description: 'Test Description'
      }) // first project
      cy.completeOnboardingStep() // team invitation
      cy.completeOnboardingStep() // integrations
      
      cy.get('[data-cy=features-tour]').should('be.visible')
      cy.get('[data-cy=feature-card]').should('have.length', 6)
      
      // Check key features
      cy.get('[data-cy=project-management-feature]').should('be.visible')
      cy.get('[data-cy=financial-tracking-feature]').should('be.visible')
      cy.get('[data-cy=team-collaboration-feature]').should('be.visible')
      cy.get('[data-cy=file-management-feature]').should('be.visible')
      cy.get('[data-cy=analytics-dashboard-feature]').should('be.visible')
      cy.get('[data-cy=ecommerce-marketplace-feature]').should('be.visible')
      
      cy.completeOnboardingStep()
      cy.url().should('include', '/onboarding/completion')
    })

    it('should complete onboarding successfully', () => {
      // Navigate through all steps quickly
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      cy.completeOnboardingStep({
        project_name: 'Test Project',
        project_description: 'Test Description'
      }) // first project
      cy.completeOnboardingStep() // team invitation
      cy.completeOnboardingStep() // integrations
      cy.completeOnboardingStep() // features tour
      
      cy.get('[data-cy=completion-message]').should('be.visible')
      cy.get('[data-cy=completion-summary]').should('be.visible')
      cy.get('[data-cy=complete-onboarding-button]').click()
      
      cy.url().should('not.include', '/onboarding')
      cy.get('[data-cy=welcome-message]').should('contain', 'Welcome to Lani')
    })

    it('should allow skipping onboarding', () => {
      cy.get('[data-cy=skip-onboarding-link]').click()
      cy.get('[data-cy=skip-confirmation-modal]').should('be.visible')
      cy.get('[data-cy=confirm-skip-button]').click()
      
      cy.url().should('not.include', '/onboarding')
      cy.get('[data-cy=onboarding-skipped-message]').should('be.visible')
    })
  })

  describe('Onboarding Progress Tracking', () => {
    it('should show progress bar throughout onboarding', () => {
      cy.get('[data-cy=progress-bar]').should('be.visible')
      cy.get('[data-cy=progress-percentage]').should('contain', '14%') // Step 1 of 7
      
      cy.get('[data-cy=next-step-button]').click()
      cy.get('[data-cy=progress-percentage]').should('contain', '29%') // Step 2 of 7
    })

    it('should save progress and allow resuming', () => {
      cy.get('[data-cy=next-step-button]').click() // Go to profile setup
      cy.completeOnboardingStep({ bio: 'Test bio' })
      
      // Simulate page refresh/navigation away
      cy.reload()
      cy.url().should('include', '/onboarding/first_project')
      cy.get('[data-cy=progress-percentage]').should('contain', '43%') // Step 3 of 7
    })

    it('should show step indicators', () => {
      cy.get('[data-cy=step-indicator]').should('contain', 'Step 1 of 7')
      cy.get('[data-cy=step-name]').should('contain', 'Welcome')
      
      cy.get('[data-cy=next-step-button]').click()
      cy.get('[data-cy=step-indicator]').should('contain', 'Step 2 of 7')
      cy.get('[data-cy=step-name]').should('contain', 'Profile Setup')
    })
  })

  describe('Onboarding Data Persistence', () => {
    it('should create sample tasks for first project', () => {
      // Complete onboarding with project creation
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      cy.completeOnboardingStep({
        project_name: 'Sample Project',
        project_description: 'A project with sample tasks'
      }) // first project
      
      // Skip to completion
      cy.completeOnboardingStep() // team invitation
      cy.completeOnboardingStep() // integrations
      cy.completeOnboardingStep() // features tour
      cy.get('[data-cy=complete-onboarding-button]').click()
      
      // Verify project and tasks were created
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').should('contain', 'Sample Project')
      cy.get('[data-cy=project-card]').first().click()
      cy.get('[data-cy=task-item]').should('have.length', 3) // Sample tasks created
    })

    it('should update user profile with onboarding data', () => {
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({
        bio: 'Updated bio from onboarding',
        timezone: 'America/Los_Angeles'
      }) // profile setup
      
      // Complete onboarding
      cy.completeOnboardingStep({
        project_name: 'Test Project',
        project_description: 'Test Description'
      }) // first project
      cy.completeOnboardingStep() // team invitation
      cy.completeOnboardingStep() // integrations
      cy.completeOnboardingStep() // features tour
      cy.get('[data-cy=complete-onboarding-button]').click()
      
      // Check profile was updated
      cy.get('[data-cy=user-menu]').click()
      cy.get('[data-cy=profile-link]').click()
      cy.get('[data-cy=user-bio]').should('contain', 'Updated bio from onboarding')
    })
  })

  describe('Onboarding Accessibility', () => {
    it('should be accessible throughout the flow', () => {
      cy.checkAccessibility()
      
      cy.get('[data-cy=next-step-button]').click()
      cy.checkAccessibility()
      
      cy.completeOnboardingStep({ bio: 'Test bio' })
      cy.checkAccessibility()
    })

    it('should support keyboard navigation', () => {
      cy.get('body').tab()
      cy.focused().should('have.attr', 'data-cy', 'next-step-button')
      
      cy.focused().type('{enter}')
      cy.url().should('include', '/onboarding/profile_setup')
    })
  })

  describe('Onboarding Error Handling', () => {
    it('should handle validation errors gracefully', () => {
      cy.get('[data-cy=next-step-button]').click() // Go to profile setup
      cy.get('[data-cy=next-step-button]').click() // Try to proceed without filling form
      
      cy.get('[data-cy=validation-errors]').should('be.visible')
      cy.url().should('include', '/onboarding/profile_setup') // Should stay on same step
    })

    it('should handle API errors during project creation', () => {
      cy.intercept('POST', '/projects', { statusCode: 500 }).as('projectError')
      
      cy.get('[data-cy=next-step-button]').click() // welcome
      cy.completeOnboardingStep({ bio: 'Test bio' }) // profile setup
      
      cy.get('[data-cy=project-name-input]').type('Test Project')
      cy.get('[data-cy=next-step-button]').click()
      
      cy.wait('@projectError')
      cy.get('[data-cy=error-message]').should('contain', 'Unable to create project')
    })
  })
})
