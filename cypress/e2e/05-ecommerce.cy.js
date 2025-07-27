// E-commerce and Medusa integration E2E tests
describe('E-commerce', () => {
  beforeEach(() => {
    cy.loginAsUser()
  })

  describe('Product Catalog', () => {
    it('should display product catalog', () => {
      cy.visit('/products')
      cy.get('[data-cy=products-grid]').should('be.visible')
      cy.get('[data-cy=product-card]').should('have.length.at.least', 1)
    })

    it('should search products', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-search-input]').type('Test Product')
      cy.get('[data-cy=search-button]').click()
      cy.get('[data-cy=product-card]').each(($product) => {
        cy.wrap($product).should('contain.text', 'Test')
      })
    })

    it('should filter products by collection', () => {
      cy.visit('/products')
      cy.get('[data-cy=collection-filter]').select('Electronics')
      cy.get('[data-cy=product-card]').should('have.length.at.least', 1)
    })

    it('should view product details', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().click()
      cy.url().should('include', '/products/')
      cy.get('[data-cy=product-title]').should('be.visible')
      cy.get('[data-cy=product-description]').should('be.visible')
      cy.get('[data-cy=product-price]').should('be.visible')
      cy.get('[data-cy=product-images]').should('be.visible')
    })

    it('should display product variants', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().click()
      cy.get('[data-cy=variant-selector]').should('be.visible')
      cy.get('[data-cy=variant-option]').should('have.length.at.least', 1)
    })
  })

  describe('Shopping Cart', () => {
    it('should add product to cart', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().click()
      cy.get('[data-cy=quantity-input]').clear().type('2')
      cy.get('[data-cy=add-to-cart-button]').click()
      cy.get('[data-cy=cart-notification]').should('contain', 'Added to cart')
      cy.get('[data-cy=cart-count]').should('contain', '2')
    })

    it('should view cart contents', () => {
      // Add item to cart first
      cy.addToCart(1, 1)
      cy.viewCart()
      
      cy.get('[data-cy=cart-items]').should('be.visible')
      cy.get('[data-cy=cart-item]').should('have.length.at.least', 1)
      cy.get('[data-cy=cart-total]').should('be.visible')
    })

    it('should update item quantity in cart', () => {
      cy.addToCart(1, 1)
      cy.viewCart()
      
      cy.get('[data-cy=cart-item]').first().within(() => {
        cy.get('[data-cy=quantity-input]').clear().type('3')
        cy.get('[data-cy=update-quantity-button]').click()
      })
      
      cy.get('[data-cy=cart-item]').first().within(() => {
        cy.get('[data-cy=quantity-display]').should('contain', '3')
      })
    })

    it('should remove item from cart', () => {
      cy.addToCart(1, 1)
      cy.viewCart()
      
      cy.get('[data-cy=cart-item]').first().within(() => {
        cy.get('[data-cy=remove-item-button]').click()
      })
      
      cy.get('[data-cy=confirm-remove-modal]').within(() => {
        cy.get('[data-cy=confirm-remove-button]').click()
      })
      
      cy.get('[data-cy=cart-empty-message]').should('be.visible')
    })

    it('should clear entire cart', () => {
      cy.addToCart(1, 2)
      cy.viewCart()
      
      cy.get('[data-cy=clear-cart-button]').click()
      cy.get('[data-cy=confirm-clear-cart]').click()
      cy.get('[data-cy=cart-empty-message]').should('be.visible')
    })
  })

  describe('Checkout Process', () => {
    beforeEach(() => {
      cy.addToCart(1, 1)
      cy.viewCart()
    })

    it('should proceed to checkout', () => {
      cy.get('[data-cy=checkout-button]').click()
      cy.url().should('include', '/checkout')
      cy.get('[data-cy=checkout-form]').should('be.visible')
    })

    it('should validate checkout form', () => {
      cy.get('[data-cy=checkout-button]').click()
      cy.get('[data-cy=place-order-button]').click()
      cy.get('[data-cy=validation-errors]').should('be.visible')
    })

    it('should complete checkout with valid information', () => {
      cy.get('[data-cy=checkout-button]').click()
      
      // Fill checkout form
      cy.get('[data-cy=shipping-name-input]').type('John Doe')
      cy.get('[data-cy=shipping-email-input]').type('john@example.com')
      cy.get('[data-cy=shipping-address-input]').type('123 Main St')
      cy.get('[data-cy=shipping-city-input]').type('Anytown')
      cy.get('[data-cy=shipping-postal-code-input]').type('12345')
      
      cy.get('[data-cy=place-order-button]').click()
      cy.get('[data-cy=order-confirmation]').should('be.visible')
      cy.url().should('include', '/orders/')
    })
  })

  describe('Order Management', () => {
    it('should view order history', () => {
      cy.visit('/orders')
      cy.get('[data-cy=orders-list]').should('be.visible')
      cy.get('[data-cy=order-item]').should('have.length.at.least', 0)
    })

    it('should view order details', () => {
      cy.visit('/orders')
      cy.get('[data-cy=order-item]').first().click()
      cy.get('[data-cy=order-details]').should('be.visible')
      cy.get('[data-cy=order-status]').should('be.visible')
      cy.get('[data-cy=order-items-list]').should('be.visible')
      cy.get('[data-cy=order-total]').should('be.visible')
    })

    it('should cancel an order', () => {
      cy.visit('/orders')
      cy.get('[data-cy=order-item]').first().click()
      cy.get('[data-cy=cancel-order-button]').click()
      cy.get('[data-cy=cancel-reason-select]').select('Changed mind')
      cy.get('[data-cy=confirm-cancel-button]').click()
      cy.get('[data-cy=order-status]').should('contain', 'Cancelled')
    })

    it('should request refund', () => {
      cy.visit('/orders')
      cy.get('[data-cy=order-item]').first().click()
      cy.get('[data-cy=request-refund-button]').click()
      cy.get('[data-cy=refund-reason-textarea]').type('Product was damaged')
      cy.get('[data-cy=submit-refund-request]').click()
      cy.get('[data-cy=refund-request-confirmation]').should('be.visible')
    })
  })

  describe('Medusa Integration', () => {
    it('should sync products from Medusa', () => {
      cy.loginAsAdmin()
      cy.visit('/admin/products')
      cy.get('[data-cy=sync-medusa-products]').click()
      cy.get('[data-cy=sync-progress]').should('be.visible')
      cy.get('[data-cy=sync-complete-message]').should('contain', 'Products synced')
    })

    it('should handle API errors gracefully', () => {
      // Mock API failure
      cy.intercept('GET', '/api/medusa/products', { statusCode: 500 }).as('apiError')
      cy.visit('/products')
      cy.wait('@apiError')
      cy.get('[data-cy=error-message]').should('contain', 'Unable to load products')
      cy.get('[data-cy=retry-button]').should('be.visible')
    })

    it('should fall back to mock data when API unavailable', () => {
      cy.intercept('GET', '/api/medusa/products', { statusCode: 503 }).as('apiUnavailable')
      cy.visit('/products')
      cy.wait('@apiUnavailable')
      cy.get('[data-cy=demo-mode-banner]').should('be.visible')
      cy.get('[data-cy=product-card]').should('have.length.at.least', 1)
    })
  })

  describe('Product Reviews and Ratings', () => {
    it('should display product ratings', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().click()
      cy.get('[data-cy=product-rating]').should('be.visible')
      cy.get('[data-cy=rating-stars]').should('be.visible')
    })

    it('should show product reviews', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().click()
      cy.get('[data-cy=reviews-section]').should('be.visible')
      cy.get('[data-cy=review-item]').should('have.length.at.least', 0)
    })
  })

  describe('Wishlist Functionality', () => {
    it('should add product to wishlist', () => {
      cy.visit('/products')
      cy.get('[data-cy=product-card]').first().within(() => {
        cy.get('[data-cy=add-to-wishlist-button]').click()
      })
      cy.get('[data-cy=wishlist-notification]').should('contain', 'Added to wishlist')
    })

    it('should view wishlist', () => {
      cy.visit('/wishlist')
      cy.get('[data-cy=wishlist-items]').should('be.visible')
    })

    it('should remove item from wishlist', () => {
      cy.visit('/wishlist')
      cy.get('[data-cy=wishlist-item]').first().within(() => {
        cy.get('[data-cy=remove-from-wishlist]').click()
      })
      cy.get('[data-cy=wishlist-item-removed]').should('be.visible')
    })
  })
})
