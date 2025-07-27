// Financial management E2E tests
describe('Financial Management', () => {
  beforeEach(() => {
    cy.loginAsPM()
    cy.visit('/projects')
    cy.get('[data-cy=project-card]').first().click()
    cy.get('[data-cy=budget-tab]').click()
  })

  describe('Budget Management', () => {
    it('should create a new budget', () => {
      const budgetData = {
        name: 'E2E Test Budget',
        amount: 5000,
        category: 'materials',
        start_date: '2024-01-01',
        end_date: '2024-12-31'
      }
      
      cy.createBudget(budgetData)
      cy.get('[data-cy=budget-card]').should('contain', budgetData.name)
      cy.get('[data-cy=budget-amount]').should('contain', '$5,000')
    })

    it('should view budget details', () => {
      cy.get('[data-cy=budget-card]').first().click()
      cy.get('[data-cy=budget-details-modal]').should('be.visible')
      cy.get('[data-cy=budget-progress-bar]').should('be.visible')
      cy.get('[data-cy=budget-utilization]').should('be.visible')
      cy.get('[data-cy=remaining-budget]').should('be.visible')
    })

    it('should edit budget information', () => {
      cy.get('[data-cy=budget-card]').first().within(() => {
        cy.get('[data-cy=edit-budget-button]').click()
      })
      
      const updatedAmount = 7500
      cy.get('[data-cy=budget-amount-input]').clear().type(updatedAmount.toString())
      cy.get('[data-cy=update-budget-button]').click()
      
      cy.get('[data-cy=budget-amount]').should('contain', '$7,500')
    })

    it('should show budget status indicators', () => {
      cy.get('[data-cy=budget-card]').first().within(() => {
        cy.get('[data-cy=budget-status]').should('be.visible')
        cy.get('[data-cy=budget-progress-bar]').should('be.visible')
      })
    })

    it('should delete a budget', () => {
      cy.get('[data-cy=budget-card]').first().within(() => {
        cy.get('[data-cy=budget-menu]').click()
        cy.get('[data-cy=delete-budget-option]').click()
      })
      
      cy.get('[data-cy=confirm-delete-modal]').within(() => {
        cy.get('[data-cy=confirm-delete-button]').click()
      })
      
      cy.get('[data-cy=success-message]').should('contain', 'Budget deleted')
    })
  })

  describe('Transaction Management', () => {
    it('should add an expense transaction', () => {
      const transactionData = {
        description: 'Test Expense',
        amount: 250,
        transaction_type: 'expense',
        category: 'materials'
      }
      
      cy.addTransaction(transactionData)
      cy.get('[data-cy=transaction-item]').should('contain', transactionData.description)
      cy.get('[data-cy=transaction-amount]').should('contain', '-$250.00')
    })

    it('should add an income transaction', () => {
      const transactionData = {
        description: 'Test Income',
        amount: 1000,
        transaction_type: 'income',
        category: 'services'
      }
      
      cy.addTransaction(transactionData)
      cy.get('[data-cy=transaction-item]').should('contain', transactionData.description)
      cy.get('[data-cy=transaction-amount]').should('contain', '+$1,000.00')
    })

    it('should view transaction details', () => {
      cy.get('[data-cy=transaction-item]').first().click()
      cy.get('[data-cy=transaction-details-modal]').should('be.visible')
      cy.get('[data-cy=transaction-date]').should('be.visible')
      cy.get('[data-cy=transaction-category]').should('be.visible')
    })

    it('should edit a transaction', () => {
      cy.get('[data-cy=transaction-item]').first().within(() => {
        cy.get('[data-cy=edit-transaction-button]').click()
      })
      
      const updatedDescription = 'Updated Transaction Description'
      cy.get('[data-cy=transaction-description-input]').clear().type(updatedDescription)
      cy.get('[data-cy=update-transaction-button]').click()
      
      cy.get('[data-cy=transaction-item]').should('contain', updatedDescription)
    })

    it('should delete a transaction', () => {
      cy.get('[data-cy=transaction-item]').first().within(() => {
        cy.get('[data-cy=transaction-menu]').click()
        cy.get('[data-cy=delete-transaction-option]').click()
      })
      
      cy.get('[data-cy=confirm-delete-modal]').within(() => {
        cy.get('[data-cy=confirm-delete-button]').click()
      })
      
      cy.get('[data-cy=success-message]').should('contain', 'Transaction deleted')
    })
  })

  describe('Financial Filtering and Search', () => {
    it('should filter transactions by type', () => {
      cy.get('[data-cy=transaction-type-filter]').select('expense')
      cy.get('[data-cy=transaction-item]').each(($transaction) => {
        cy.wrap($transaction).find('[data-cy=transaction-amount]').should('contain', '-')
      })
    })

    it('should filter transactions by category', () => {
      cy.get('[data-cy=transaction-category-filter]').select('materials')
      cy.get('[data-cy=transaction-item]').each(($transaction) => {
        cy.wrap($transaction).find('[data-cy=transaction-category]').should('contain', 'Materials')
      })
    })

    it('should filter transactions by date range', () => {
      cy.get('[data-cy=date-range-start]').type('2024-01-01')
      cy.get('[data-cy=date-range-end]').type('2024-12-31')
      cy.get('[data-cy=apply-date-filter]').click()
      cy.get('[data-cy=transaction-item]').should('have.length.at.least', 1)
    })

    it('should search transactions by description', () => {
      cy.get('[data-cy=transaction-search-input]').type('Test')
      cy.get('[data-cy=transaction-search-button]').click()
      cy.get('[data-cy=transaction-item]').each(($transaction) => {
        cy.wrap($transaction).should('contain.text', 'Test')
      })
    })
  })

  describe('Financial Analytics', () => {
    it('should display budget utilization chart', () => {
      cy.get('[data-cy=budget-chart-container]').should('be.visible')
      cy.waitForCharts()
      cy.get('[data-cy=budget-chart]').should('be.visible')
    })

    it('should show spending trends', () => {
      cy.get('[data-cy=spending-trends-chart]').should('be.visible')
      cy.waitForCharts()
      cy.get('[data-cy=monthly-spending-chart]').should('be.visible')
    })

    it('should display financial summary', () => {
      cy.get('[data-cy=financial-summary]').should('be.visible')
      cy.get('[data-cy=total-budget]').should('be.visible')
      cy.get('[data-cy=total-spent]').should('be.visible')
      cy.get('[data-cy=remaining-budget]').should('be.visible')
      cy.get('[data-cy=budget-utilization-percentage]').should('be.visible')
    })

    it('should show category breakdown', () => {
      cy.get('[data-cy=category-breakdown]').should('be.visible')
      cy.get('[data-cy=category-item]').should('have.length.at.least', 1)
      cy.get('[data-cy=category-amount]').should('be.visible')
      cy.get('[data-cy=category-percentage]').should('be.visible')
    })
  })

  describe('Maybe Finance Integration', () => {
    it('should sync with Maybe Finance API', () => {
      cy.get('[data-cy=maybe-sync-button]').click()
      cy.get('[data-cy=sync-progress]').should('be.visible')
      cy.get('[data-cy=sync-success-message]').should('contain', 'Synced with Maybe Finance')
    })

    it('should export to Maybe Finance', () => {
      cy.get('[data-cy=export-to-maybe-button]').click()
      cy.get('[data-cy=export-options-modal]').should('be.visible')
      cy.get('[data-cy=export-date-range]').should('be.visible')
      cy.get('[data-cy=confirm-export-button]').click()
      cy.get('[data-cy=export-success-message]').should('contain', 'Exported to Maybe Finance')
    })
  })

  describe('Financial Reports', () => {
    it('should generate financial report', () => {
      cy.get('[data-cy=generate-report-button]').click()
      cy.get('[data-cy=report-options-modal]').should('be.visible')
      cy.get('[data-cy=report-type-select]').select('financial_summary')
      cy.get('[data-cy=generate-report-confirm]').click()
      cy.get('[data-cy=report-generated-message]').should('be.visible')
    })

    it('should export financial data to PDF', () => {
      cy.get('[data-cy=export-pdf-button]').click()
      cy.get('[data-cy=pdf-export-progress]').should('be.visible')
      // Note: Actual PDF download testing would require additional setup
    })
  })
})
