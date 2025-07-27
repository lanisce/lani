// Test utilities and helpers unit tests
import { describe, it, expect, vi, beforeEach } from 'vitest'

// Mock utility functions that might be used across the application
const testHelpers = {
  // Format currency for display
  formatCurrency: (amount, currency = 'USD') => {
    // Handle edge cases
    if (amount === null || amount === undefined || amount === '') {
      amount = 0
    }
    return new Intl.NumberFormat('en-US', {
      style: 'currency',
      currency: currency
    }).format(amount)
  },

  // Format date for display
  formatDate: (date, options = {}) => {
    const defaultOptions = { 
      year: 'numeric', 
      month: 'short', 
      day: 'numeric' 
    }
    return new Date(date).toLocaleDateString('en-US', { ...defaultOptions, ...options })
  },

  // Debounce function for search inputs
  debounce: (func, wait) => {
    let timeout
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout)
        func(...args)
      }
      clearTimeout(timeout)
      timeout = setTimeout(later, wait)
    }
  },

  // Validate email format
  isValidEmail: (email) => {
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/
    return emailRegex.test(email)
  },

  // Generate random ID
  generateId: () => {
    return Math.random().toString(36).substr(2, 9)
  },

  // Deep clone object
  deepClone: (obj) => {
    if (obj === null || obj === undefined) {
      return obj
    }
    return JSON.parse(JSON.stringify(obj))
  },

  // Capitalize first letter
  capitalize: (str) => {
    return str.charAt(0).toUpperCase() + str.slice(1)
  },

  // Truncate text with ellipsis
  truncate: (text, maxLength = 50) => {
    if (text.length <= maxLength) return text
    return text.substr(0, maxLength) + '...'
  }
}

describe('Test Helpers and Utilities', () => {
  describe('formatCurrency', () => {
    it('should format USD currency correctly', () => {
      expect(testHelpers.formatCurrency(1234.56)).toBe('$1,234.56')
      expect(testHelpers.formatCurrency(0)).toBe('$0.00')
      expect(testHelpers.formatCurrency(-500.25)).toBe('-$500.25')
    })

    it('should handle different currencies', () => {
      expect(testHelpers.formatCurrency(1000, 'EUR')).toContain('€1,000.00')
      expect(testHelpers.formatCurrency(1000, 'GBP')).toContain('£1,000.00')
    })

    it('should handle edge cases', () => {
      expect(testHelpers.formatCurrency(null)).toBe('$0.00')
      expect(testHelpers.formatCurrency(undefined)).toBe('$0.00')
      expect(testHelpers.formatCurrency('')).toBe('$0.00')
    })
  })

  describe('formatDate', () => {
    it('should format dates correctly', () => {
      const date = new Date('2024-01-15')
      const formatted = testHelpers.formatDate(date)
      expect(formatted).toMatch(/Jan 15, 2024/)
    })

    it('should handle custom options', () => {
      const date = new Date('2024-01-15')
      const formatted = testHelpers.formatDate(date, { 
        weekday: 'long',
        year: 'numeric',
        month: 'long',
        day: 'numeric'
      })
      expect(formatted).toContain('January')
      expect(formatted).toContain('2024')
    })

    it('should handle invalid dates', () => {
      expect(() => testHelpers.formatDate('invalid-date')).not.toThrow()
    })
  })

  describe('debounce', () => {
    it('should delay function execution', async () => {
      const mockFn = vi.fn()
      const debouncedFn = testHelpers.debounce(mockFn, 100)

      debouncedFn('test')
      expect(mockFn).not.toHaveBeenCalled()

      await new Promise(resolve => setTimeout(resolve, 150))
      expect(mockFn).toHaveBeenCalledWith('test')
    })

    it('should cancel previous calls', async () => {
      const mockFn = vi.fn()
      const debouncedFn = testHelpers.debounce(mockFn, 100)

      debouncedFn('first')
      debouncedFn('second')
      debouncedFn('third')

      await new Promise(resolve => setTimeout(resolve, 150))
      expect(mockFn).toHaveBeenCalledTimes(1)
      expect(mockFn).toHaveBeenCalledWith('third')
    })
  })

  describe('isValidEmail', () => {
    it('should validate correct email formats', () => {
      expect(testHelpers.isValidEmail('user@example.com')).toBe(true)
      expect(testHelpers.isValidEmail('test.email+tag@domain.co.uk')).toBe(true)
      expect(testHelpers.isValidEmail('user123@test-domain.org')).toBe(true)
    })

    it('should reject invalid email formats', () => {
      expect(testHelpers.isValidEmail('invalid-email')).toBe(false)
      expect(testHelpers.isValidEmail('user@')).toBe(false)
      expect(testHelpers.isValidEmail('@domain.com')).toBe(false)
      expect(testHelpers.isValidEmail('user@domain')).toBe(false)
      expect(testHelpers.isValidEmail('')).toBe(false)
    })
  })

  describe('generateId', () => {
    it('should generate unique IDs', () => {
      const id1 = testHelpers.generateId()
      const id2 = testHelpers.generateId()
      
      expect(id1).toBeTruthy()
      expect(id2).toBeTruthy()
      expect(id1).not.toBe(id2)
      expect(typeof id1).toBe('string')
      expect(id1.length).toBeGreaterThan(0)
    })

    it('should generate IDs of consistent format', () => {
      const ids = Array.from({ length: 10 }, () => testHelpers.generateId())
      
      ids.forEach(id => {
        expect(id).toMatch(/^[a-z0-9]+$/)
        expect(id.length).toBeGreaterThan(5)
      })
    })
  })

  describe('deepClone', () => {
    it('should create deep copy of objects', () => {
      const original = {
        name: 'Test',
        nested: {
          value: 42,
          array: [1, 2, 3]
        }
      }

      const cloned = testHelpers.deepClone(original)
      
      expect(cloned).toEqual(original)
      expect(cloned).not.toBe(original)
      expect(cloned.nested).not.toBe(original.nested)
      expect(cloned.nested.array).not.toBe(original.nested.array)
    })

    it('should handle arrays', () => {
      const original = [1, { a: 2 }, [3, 4]]
      const cloned = testHelpers.deepClone(original)
      
      expect(cloned).toEqual(original)
      expect(cloned).not.toBe(original)
      expect(cloned[1]).not.toBe(original[1])
    })

    it('should handle null and undefined', () => {
      expect(testHelpers.deepClone(null)).toBe(null)
      expect(testHelpers.deepClone(undefined)).toBe(undefined)
    })
  })

  describe('capitalize', () => {
    it('should capitalize first letter', () => {
      expect(testHelpers.capitalize('hello')).toBe('Hello')
      expect(testHelpers.capitalize('world')).toBe('World')
      expect(testHelpers.capitalize('test string')).toBe('Test string')
    })

    it('should handle edge cases', () => {
      expect(testHelpers.capitalize('')).toBe('')
      expect(testHelpers.capitalize('a')).toBe('A')
      expect(testHelpers.capitalize('A')).toBe('A')
    })
  })

  describe('truncate', () => {
    it('should truncate long text', () => {
      const longText = 'This is a very long text that should be truncated'
      const truncated = testHelpers.truncate(longText, 20)
      
      expect(truncated).toBe('This is a very long ...')
      expect(truncated.length).toBe(23) // 20 + '...'
    })

    it('should not truncate short text', () => {
      const shortText = 'Short text'
      const result = testHelpers.truncate(shortText, 20)
      
      expect(result).toBe(shortText)
    })

    it('should use default max length', () => {
      const text = 'A'.repeat(60)
      const truncated = testHelpers.truncate(text)
      
      expect(truncated.length).toBe(53) // 50 + '...'
    })
  })
})

// Integration test helpers
describe('Integration Test Helpers', () => {
  describe('DOM Manipulation Helpers', () => {
    it('should create test elements', () => {
      const element = document.createElement('div')
      element.setAttribute('data-testid', 'test-element')
      element.textContent = 'Test Content'
      
      expect(element.getAttribute('data-testid')).toBe('test-element')
      expect(element.textContent).toBe('Test Content')
    })

    it('should simulate user interactions', () => {
      const button = document.createElement('button')
      const clickHandler = vi.fn()
      button.addEventListener('click', clickHandler)
      
      button.click()
      expect(clickHandler).toHaveBeenCalledTimes(1)
    })
  })

  describe('Mock Data Generators', () => {
    it('should generate mock user data', () => {
      const mockUser = {
        id: testHelpers.generateId(),
        name: 'Test User',
        email: 'test@example.com',
        role: 'member',
        created_at: new Date().toISOString()
      }
      
      expect(testHelpers.isValidEmail(mockUser.email)).toBe(true)
      expect(mockUser.id).toBeTruthy()
      expect(mockUser.name).toBe('Test User')
    })

    it('should generate mock project data', () => {
      const mockProject = {
        id: testHelpers.generateId(),
        name: 'Test Project',
        description: 'A test project for unit testing',
        status: 'active',
        budget_limit: 10000,
        created_at: new Date().toISOString()
      }
      
      expect(mockProject.id).toBeTruthy()
      expect(mockProject.status).toBe('active')
      expect(typeof mockProject.budget_limit).toBe('number')
    })

    it('should generate mock task data', () => {
      const mockTask = {
        id: testHelpers.generateId(),
        title: 'Test Task',
        description: 'A test task for unit testing',
        status: 'pending',
        priority: 'medium',
        due_date: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()
      }
      
      expect(mockTask.id).toBeTruthy()
      expect(mockTask.status).toBe('pending')
      expect(new Date(mockTask.due_date)).toBeInstanceOf(Date)
    })
  })

  describe('API Mock Helpers', () => {
    it('should create successful API response', () => {
      const successResponse = {
        ok: true,
        status: 200,
        json: async () => ({ success: true, data: { id: 1 } })
      }
      
      expect(successResponse.ok).toBe(true)
      expect(successResponse.status).toBe(200)
    })

    it('should create error API response', () => {
      const errorResponse = {
        ok: false,
        status: 422,
        json: async () => ({ errors: ['Validation failed'] })
      }
      
      expect(errorResponse.ok).toBe(false)
      expect(errorResponse.status).toBe(422)
    })
  })
})
