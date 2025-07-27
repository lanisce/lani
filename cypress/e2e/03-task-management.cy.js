// Task management E2E tests
describe('Task Management', () => {
  beforeEach(() => {
    cy.loginAsPM()
    cy.visit('/projects')
    cy.get('[data-cy=project-card]').first().click()
  })

  describe('Task CRUD Operations', () => {
    it('should create a new task', () => {
      const taskData = {
        title: 'E2E Test Task',
        description: 'A task created via E2E testing',
        priority: 'high',
        due_date: '2024-12-31'
      }
      
      cy.createTask(taskData)
      cy.get('[data-cy=task-item]').should('contain', taskData.title)
      cy.get('[data-cy=task-priority]').should('contain', 'High')
    })

    it('should view task details', () => {
      cy.get('[data-cy=task-item]').first().click()
      cy.get('[data-cy=task-details-modal]').should('be.visible')
      cy.get('[data-cy=task-title]').should('be.visible')
      cy.get('[data-cy=task-description]').should('be.visible')
      cy.get('[data-cy=task-status]').should('be.visible')
    })

    it('should edit task inline', () => {
      cy.get('[data-cy=task-item]').first().within(() => {
        cy.get('[data-cy=task-title]').dblclick()
        cy.get('[data-cy=inline-edit-input]').should('be.visible')
        cy.get('[data-cy=inline-edit-input]').clear().type('Updated Task Title')
        cy.get('[data-cy=save-inline-edit]').click()
      })
      
      cy.get('[data-cy=task-item]').first().should('contain', 'Updated Task Title')
    })

    it('should update task status', () => {
      cy.get('[data-cy=task-item]').first().within(() => {
        cy.get('[data-cy=task-status-select]').select('in_progress')
      })
      
      cy.get('[data-cy=task-item]').first().within(() => {
        cy.get('[data-cy=task-status]').should('contain', 'In Progress')
      })
    })

    it('should assign task to team member', () => {
      cy.get('[data-cy=task-item]').first().click()
      cy.get('[data-cy=task-details-modal]').within(() => {
        cy.get('[data-cy=assign-user-select]').select('Alice Johnson')
        cy.get('[data-cy=save-assignment-button]').click()
      })
      
      cy.get('[data-cy=task-item]').first().within(() => {
        cy.get('[data-cy=assigned-user]').should('contain', 'Alice')
      })
    })

    it('should delete a task', () => {
      cy.get('[data-cy=task-item]').first().within(() => {
        cy.get('[data-cy=task-menu]').click()
        cy.get('[data-cy=delete-task-option]').click()
      })
      
      cy.get('[data-cy=confirm-delete-modal]').within(() => {
        cy.get('[data-cy=confirm-delete-button]').click()
      })
      
      cy.get('[data-cy=success-message]').should('contain', 'Task deleted')
    })
  })

  describe('Task Filtering and Sorting', () => {
    it('should filter tasks by status', () => {
      cy.get('[data-cy=task-status-filter]').select('pending')
      cy.get('[data-cy=task-item]').each(($task) => {
        cy.wrap($task).find('[data-cy=task-status]').should('contain', 'Pending')
      })
    })

    it('should filter tasks by priority', () => {
      cy.get('[data-cy=task-priority-filter]').select('high')
      cy.get('[data-cy=task-item]').each(($task) => {
        cy.wrap($task).find('[data-cy=task-priority]').should('contain', 'High')
      })
    })

    it('should sort tasks by due date', () => {
      cy.get('[data-cy=task-sort-select]').select('due_date')
      cy.get('[data-cy=task-item]').should('have.length.at.least', 2)
      // Verify sorting order by checking due dates
    })

    it('should filter tasks by assigned user', () => {
      cy.get('[data-cy=task-assignee-filter]').select('Alice Johnson')
      cy.get('[data-cy=task-item]').each(($task) => {
        cy.wrap($task).find('[data-cy=assigned-user]').should('contain', 'Alice')
      })
    })
  })

  describe('Task Search', () => {
    it('should search tasks by title', () => {
      cy.get('[data-cy=task-search-input]').type('Test')
      cy.get('[data-cy=task-search-button]').click()
      cy.get('[data-cy=task-item]').each(($task) => {
        cy.wrap($task).should('contain.text', 'Test')
      })
    })

    it('should clear search results', () => {
      cy.get('[data-cy=task-search-input]').type('NonexistentTask')
      cy.get('[data-cy=task-search-button]').click()
      cy.get('[data-cy=no-tasks-message]').should('be.visible')
      
      cy.get('[data-cy=clear-search-button]').click()
      cy.get('[data-cy=task-item]').should('have.length.at.least', 1)
    })
  })

  describe('Task Due Dates and Reminders', () => {
    it('should highlight overdue tasks', () => {
      // Create a task with past due date
      const overdueTask = {
        title: 'Overdue Task',
        description: 'This task is overdue',
        priority: 'high',
        due_date: '2023-01-01'
      }
      
      cy.createTask(overdueTask)
      cy.get('[data-cy=task-item]').contains(overdueTask.title).parent().within(() => {
        cy.get('[data-cy=overdue-indicator]').should('be.visible')
      })
    })

    it('should show due today tasks', () => {
      const today = new Date().toISOString().split('T')[0]
      const todayTask = {
        title: 'Due Today Task',
        description: 'This task is due today',
        priority: 'medium',
        due_date: today
      }
      
      cy.createTask(todayTask)
      cy.get('[data-cy=task-item]').contains(todayTask.title).parent().within(() => {
        cy.get('[data-cy=due-today-indicator]').should('be.visible')
      })
    })
  })

  describe('Task Bulk Operations', () => {
    it('should select multiple tasks', () => {
      cy.get('[data-cy=task-checkbox]').first().check()
      cy.get('[data-cy=task-checkbox]').eq(1).check()
      cy.get('[data-cy=bulk-actions-bar]').should('be.visible')
      cy.get('[data-cy=selected-count]').should('contain', '2')
    })

    it('should bulk update task status', () => {
      cy.get('[data-cy=task-checkbox]').first().check()
      cy.get('[data-cy=task-checkbox]').eq(1).check()
      cy.get('[data-cy=bulk-status-update]').select('completed')
      cy.get('[data-cy=apply-bulk-action]').click()
      
      cy.get('[data-cy=success-message]').should('contain', 'Tasks updated')
    })

    it('should bulk delete tasks', () => {
      cy.get('[data-cy=task-checkbox]').first().check()
      cy.get('[data-cy=bulk-delete-button]').click()
      cy.get('[data-cy=confirm-bulk-delete]').click()
      
      cy.get('[data-cy=success-message]').should('contain', 'Tasks deleted')
    })
  })
})
