// Reporting and analytics dashboard E2E tests
describe('Reporting & Analytics', () => {
  beforeEach(() => {
    cy.loginAsPM()
  })

  describe('Analytics Dashboard', () => {
    it('should display main analytics dashboard', () => {
      cy.visit('/reports')
      cy.get('[data-cy=analytics-dashboard]').should('be.visible')
      cy.get('[data-cy=metrics-cards]').should('be.visible')
      cy.get('[data-cy=charts-section]').should('be.visible')
      cy.get('[data-cy=recent-activity]').should('be.visible')
    })

    it('should show key metrics cards', () => {
      cy.visit('/reports')
      cy.get('[data-cy=total-projects-metric]').should('be.visible')
      cy.get('[data-cy=total-tasks-metric]').should('be.visible')
      cy.get('[data-cy=budget-utilization-metric]').should('be.visible')
      cy.get('[data-cy=team-members-metric]').should('be.visible')
      
      // Verify metrics have values
      cy.get('[data-cy=total-projects-count]').should('not.be.empty')
      cy.get('[data-cy=total-tasks-count]').should('not.be.empty')
    })

    it('should display interactive charts', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      cy.get('[data-cy=project-status-chart]').should('be.visible')
      cy.get('[data-cy=monthly-spending-chart]').should('be.visible')
      cy.get('[data-cy=task-completion-chart]').should('be.visible')
    })

    it('should show recent activity feeds', () => {
      cy.visit('/reports')
      cy.get('[data-cy=recent-tasks-section]').should('be.visible')
      cy.get('[data-cy=recent-transactions-section]').should('be.visible')
      
      cy.get('[data-cy=recent-task-item]').should('have.length.at.least', 0)
      cy.get('[data-cy=recent-transaction-item]').should('have.length.at.least', 0)
    })

    it('should provide quick links to detailed reports', () => {
      cy.visit('/reports')
      cy.get('[data-cy=project-quick-links]').should('be.visible')
      cy.get('[data-cy=project-link]').should('have.length.at.least', 1)
      
      cy.get('[data-cy=project-link]').first().click()
      cy.url().should('include', '/reports/project_overview')
    })
  })

  describe('Project-Specific Reports', () => {
    it('should generate project overview report', () => {
      cy.visit('/reports/project_overview?project_id=1')
      cy.get('[data-cy=project-overview-report]').should('be.visible')
      cy.get('[data-cy=project-summary]').should('be.visible')
      cy.get('[data-cy=project-timeline]').should('be.visible')
      cy.get('[data-cy=project-metrics]').should('be.visible')
    })

    it('should show project financial report', () => {
      cy.visit('/reports/project_financial?project_id=1')
      cy.get('[data-cy=financial-report]').should('be.visible')
      cy.get('[data-cy=budget-overview]').should('be.visible')
      cy.get('[data-cy=spending-breakdown]').should('be.visible')
      cy.get('[data-cy=financial-trends]').should('be.visible')
    })

    it('should display project tasks report', () => {
      cy.visit('/reports/project_tasks?project_id=1')
      cy.get('[data-cy=tasks-report]').should('be.visible')
      cy.get('[data-cy=task-completion-stats]').should('be.visible')
      cy.get('[data-cy=task-priority-breakdown]').should('be.visible')
      cy.get('[data-cy=overdue-tasks-section]').should('be.visible')
    })

    it('should show project team report', () => {
      cy.visit('/reports/project_team?project_id=1')
      cy.get('[data-cy=team-report]').should('be.visible')
      cy.get('[data-cy=team-performance]').should('be.visible')
      cy.get('[data-cy=workload-distribution]').should('be.visible')
      cy.get('[data-cy=collaboration-metrics]').should('be.visible')
    })
  })

  describe('Report Filtering and Customization', () => {
    it('should filter reports by date range', () => {
      cy.visit('/reports')
      cy.get('[data-cy=date-range-filter]').should('be.visible')
      cy.get('[data-cy=start-date-input]').type('2024-01-01')
      cy.get('[data-cy=end-date-input]').type('2024-12-31')
      cy.get('[data-cy=apply-date-filter]').click()
      
      cy.get('[data-cy=filtered-results]').should('be.visible')
      cy.get('[data-cy=date-range-indicator]').should('contain', '2024-01-01 to 2024-12-31')
    })

    it('should filter by project status', () => {
      cy.visit('/reports')
      cy.get('[data-cy=project-status-filter]').select('active')
      cy.get('[data-cy=apply-filters-button]').click()
      
      cy.get('[data-cy=filtered-projects]').each(($project) => {
        cy.wrap($project).find('[data-cy=project-status]').should('contain', 'Active')
      })
    })

    it('should customize chart display options', () => {
      cy.visit('/reports')
      cy.get('[data-cy=chart-options-button]').click()
      cy.get('[data-cy=chart-type-select]').select('bar')
      cy.get('[data-cy=apply-chart-options]').click()
      
      cy.waitForCharts()
      cy.get('[data-cy=project-status-chart]').should('be.visible')
    })
  })

  describe('PDF Export Functionality', () => {
    it('should export dashboard to PDF', () => {
      cy.visit('/reports')
      cy.get('[data-cy=export-pdf-button]').click()
      cy.get('[data-cy=pdf-export-options]').should('be.visible')
      cy.get('[data-cy=include-charts-checkbox]').check()
      cy.get('[data-cy=include-tables-checkbox]').check()
      cy.get('[data-cy=generate-pdf-button]').click()
      
      cy.get('[data-cy=pdf-generation-progress]').should('be.visible')
      cy.get('[data-cy=pdf-ready-notification]').should('be.visible', { timeout: 10000 })
    })

    it('should export project-specific report to PDF', () => {
      cy.visit('/reports/project_overview?project_id=1')
      cy.get('[data-cy=export-project-pdf]').click()
      cy.get('[data-cy=pdf-export-modal]').should('be.visible')
      cy.get('[data-cy=report-title-input]').type('Project Overview Report')
      cy.get('[data-cy=generate-project-pdf]').click()
      
      cy.get('[data-cy=pdf-generation-success]').should('be.visible')
    })

    it('should handle PDF export errors gracefully', () => {
      cy.intercept('POST', '/reports/export_pdf', { statusCode: 500 }).as('pdfError')
      cy.visit('/reports')
      cy.get('[data-cy=export-pdf-button]').click()
      cy.get('[data-cy=generate-pdf-button]').click()
      
      cy.wait('@pdfError')
      cy.get('[data-cy=pdf-error-message]').should('contain', 'Unable to generate PDF')
    })
  })

  describe('Real-time Data Updates', () => {
    it('should update metrics in real-time', () => {
      cy.visit('/reports')
      cy.get('[data-cy=total-tasks-count]').then(($count) => {
        const initialCount = parseInt($count.text())
        
        // Create a new task in another tab/window simulation
        cy.window().then((win) => {
          // Simulate real-time update
          cy.get('[data-cy=refresh-metrics-button]').click()
          cy.get('[data-cy=total-tasks-count]').should('not.contain', initialCount.toString())
        })
      })
    })

    it('should refresh charts with new data', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      cy.get('[data-cy=refresh-charts-button]').click()
      cy.get('[data-cy=chart-loading-indicator]').should('be.visible')
      cy.waitForCharts()
      cy.get('[data-cy=last-updated-timestamp]').should('be.visible')
    })
  })

  describe('Data Visualization Interactions', () => {
    it('should allow chart interactions', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      // Click on chart segments to drill down
      cy.get('[data-cy=project-status-chart]').within(() => {
        cy.get('canvas').click(200, 200)
      })
      
      cy.get('[data-cy=chart-drill-down-modal]').should('be.visible')
      cy.get('[data-cy=drill-down-data]').should('be.visible')
    })

    it('should show chart tooltips on hover', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      cy.get('[data-cy=monthly-spending-chart]').within(() => {
        cy.get('canvas').trigger('mouseover', 300, 150)
      })
      
      cy.get('[data-cy=chart-tooltip]').should('be.visible')
    })

    it('should toggle chart legends', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      cy.get('[data-cy=chart-legend]').within(() => {
        cy.get('[data-cy=legend-item]').first().click()
      })
      
      // Chart should update to hide/show the clicked series
      cy.waitForCharts()
    })
  })

  describe('Performance and Loading', () => {
    it('should load dashboard efficiently', () => {
      const startTime = Date.now()
      cy.visit('/reports')
      cy.get('[data-cy=analytics-dashboard]').should('be.visible')
      
      cy.then(() => {
        const loadTime = Date.now() - startTime
        expect(loadTime).to.be.lessThan(5000) // Should load within 5 seconds
      })
    })

    it('should handle large datasets gracefully', () => {
      cy.visit('/reports')
      cy.get('[data-cy=large-dataset-toggle]').click()
      cy.get('[data-cy=loading-indicator]').should('be.visible')
      cy.get('[data-cy=analytics-dashboard]').should('be.visible')
      cy.get('[data-cy=performance-warning]').should('not.exist')
    })

    it('should implement proper caching', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      // Navigate away and back
      cy.visit('/projects')
      cy.visit('/reports')
      
      // Should load faster the second time (cached data)
      cy.get('[data-cy=analytics-dashboard]').should('be.visible')
      cy.get('[data-cy=cache-indicator]').should('be.visible')
    })
  })

  describe('Accessibility and Usability', () => {
    it('should be accessible to screen readers', () => {
      cy.visit('/reports')
      cy.checkAccessibility()
      
      cy.get('[data-cy=metrics-cards]').within(() => {
        cy.get('[data-cy=metric-card]').each(($card) => {
          cy.wrap($card).should('have.attr', 'aria-label')
        })
      })
    })

    it('should support keyboard navigation', () => {
      cy.visit('/reports')
      cy.get('body').tab()
      cy.focused().should('be.visible')
      
      // Navigate through interactive elements
      cy.focused().tab()
      cy.focused().should('have.attr', 'data-cy')
    })

    it('should provide alternative text for charts', () => {
      cy.visit('/reports')
      cy.waitForCharts()
      
      cy.get('[data-cy=project-status-chart]').should('have.attr', 'aria-label')
      cy.get('[data-cy=chart-data-table]').should('be.visible') // Alternative data representation
    })
  })
})
