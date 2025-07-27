// Project management E2E tests
describe('Project Management', () => {
  beforeEach(() => {
    cy.loginAsPM()
  })

  describe('Project CRUD Operations', () => {
    it('should create a new project', () => {
      const projectData = {
        name: 'Test Project E2E',
        description: 'A test project created via E2E testing',
        status: 'active'
      }
      
      cy.createProject(projectData)
      cy.get('[data-cy=project-title]').should('contain', projectData.name)
      cy.get('[data-cy=project-description]').should('contain', projectData.description)
    })

    it('should list all projects', () => {
      cy.visit('/projects')
      cy.get('[data-cy=projects-list]').should('be.visible')
      cy.get('[data-cy=project-card]').should('have.length.at.least', 1)
    })

    it('should view project details', () => {
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').first().click()
      cy.url().should('include', '/projects/')
      cy.get('[data-cy=project-details]').should('be.visible')
      cy.get('[data-cy=tasks-section]').should('be.visible')
      cy.get('[data-cy=budget-section]').should('be.visible')
      cy.get('[data-cy=team-section]').should('be.visible')
    })

    it('should edit project information', () => {
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').first().click()
      cy.get('[data-cy=edit-project-button]').click()
      
      const updatedName = 'Updated Project Name'
      cy.get('[data-cy=project-name-input]').clear().type(updatedName)
      cy.get('[data-cy=update-project-button]').click()
      
      cy.get('[data-cy=project-title]').should('contain', updatedName)
    })

    it('should delete a project', () => {
      // Create a project to delete
      const projectData = {
        name: 'Project to Delete',
        description: 'This project will be deleted',
        status: 'active'
      }
      
      cy.createProject(projectData)
      cy.get('[data-cy=delete-project-button]').click()
      cy.get('[data-cy=confirm-delete-button]').click()
      
      cy.url().should('include', '/projects')
      cy.get('[data-cy=success-message]').should('contain', 'deleted')
    })
  })

  describe('Project Status Management', () => {
    it('should change project status', () => {
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').first().click()
      cy.get('[data-cy=project-status-select]').select('completed')
      cy.get('[data-cy=update-status-button]').click()
      cy.get('[data-cy=project-status]').should('contain', 'Completed')
    })
  })

  describe('Project Location Features', () => {
    it('should set project location using map', () => {
      cy.visit('/projects/new')
      cy.get('[data-cy=project-name-input]').type('Location Test Project')
      cy.get('[data-cy=map-container]').should('be.visible')
      
      // Click on map to set location
      cy.get('[data-cy=map-container]').click(400, 300)
      cy.get('[data-cy=latitude-input]').should('not.be.empty')
      cy.get('[data-cy=longitude-input]').should('not.be.empty')
      
      cy.get('[data-cy=create-project-button]').click()
      cy.get('[data-cy=project-location]').should('be.visible')
    })
  })

  describe('Project Team Management', () => {
    it('should view team members', () => {
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').first().click()
      cy.get('[data-cy=team-section]').should('be.visible')
      cy.get('[data-cy=team-member]').should('have.length.at.least', 1)
    })

    it('should show team member roles', () => {
      cy.visit('/projects')
      cy.get('[data-cy=project-card]').first().click()
      cy.get('[data-cy=team-member]').first().within(() => {
        cy.get('[data-cy=member-role]').should('be.visible')
        cy.get('[data-cy=member-name]').should('be.visible')
      })
    })
  })

  describe('Project Search and Filtering', () => {
    it('should search projects by name', () => {
      cy.visit('/projects')
      cy.get('[data-cy=search-input]').type('Test')
      cy.get('[data-cy=search-button]').click()
      cy.get('[data-cy=project-card]').each(($card) => {
        cy.wrap($card).should('contain.text', 'Test')
      })
    })

    it('should filter projects by status', () => {
      cy.visit('/projects')
      cy.get('[data-cy=status-filter]').select('active')
      cy.get('[data-cy=project-card]').each(($card) => {
        cy.wrap($card).find('[data-cy=project-status]').should('contain', 'Active')
      })
    })
  })
})
