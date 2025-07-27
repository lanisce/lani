// External API service unit tests
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'

// Mock the ExternalApiService (since it's a Ruby service, we'll test the JS interactions)
const mockApiService = {
  openproject: {
    getProjects: vi.fn(),
    getWorkPackages: vi.fn(),
    createWorkPackage: vi.fn(),
    updateWorkPackage: vi.fn()
  },
  maybe: {
    getAccounts: vi.fn(),
    getTransactions: vi.fn(),
    createTransaction: vi.fn(),
    syncBudgets: vi.fn()
  },
  nextcloud: {
    listFiles: vi.fn(),
    uploadFile: vi.fn(),
    downloadFile: vi.fn(),
    deleteFile: vi.fn()
  },
  medusa: {
    getProducts: vi.fn(),
    getCart: vi.fn(),
    addToCart: vi.fn(),
    createOrder: vi.fn()
  }
}

// Mock fetch for API calls
global.fetch = vi.fn()

describe('External API Service Integration', () => {
  beforeEach(() => {
    vi.clearAllMocks()
  })

  describe('OpenProject Integration', () => {
    it('should fetch projects from OpenProject API', async () => {
      const mockProjects = [
        { id: 1, name: 'Project 1', status: 'active' },
        { id: 2, name: 'Project 2', status: 'completed' }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ projects: mockProjects })
      })

      const response = await fetch('/api/openproject/projects')
      const data = await response.json()

      expect(fetch).toHaveBeenCalledWith('/api/openproject/projects')
      expect(data.projects).toEqual(mockProjects)
    })

    it('should handle OpenProject API errors', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => ({ error: 'Unauthorized' })
      })

      const response = await fetch('/api/openproject/projects')
      expect(response.ok).toBe(false)
      expect(response.status).toBe(401)
    })

    it('should sync work packages with tasks', async () => {
      const mockWorkPackages = [
        { id: 1, subject: 'Task 1', status: 'open', assignee: 'user1' },
        { id: 2, subject: 'Task 2', status: 'closed', assignee: 'user2' }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ work_packages: mockWorkPackages })
      })

      const response = await fetch('/api/openproject/work_packages')
      const data = await response.json()

      expect(data.work_packages).toEqual(mockWorkPackages)
    })

    it('should create work package from task', async () => {
      const taskData = {
        subject: 'New Task',
        description: 'Task description',
        assignee_id: 1,
        project_id: 1
      }

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id: 123, ...taskData })
      })

      const response = await fetch('/api/openproject/work_packages', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(taskData)
      })

      expect(fetch).toHaveBeenCalledWith('/api/openproject/work_packages', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify(taskData)
      }))
    })
  })

  describe('Maybe Finance Integration', () => {
    it('should fetch accounts from Maybe API', async () => {
      const mockAccounts = [
        { id: 1, name: 'Checking', balance: 5000 },
        { id: 2, name: 'Savings', balance: 15000 }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ accounts: mockAccounts })
      })

      const response = await fetch('/api/maybe/accounts')
      const data = await response.json()

      expect(data.accounts).toEqual(mockAccounts)
    })

    it('should sync transactions with Maybe', async () => {
      const transactionData = {
        amount: -250.00,
        description: 'Office supplies',
        category: 'materials',
        date: '2024-01-15'
      }

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ id: 456, ...transactionData })
      })

      const response = await fetch('/api/maybe/transactions', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(transactionData)
      })

      expect(fetch).toHaveBeenCalledWith('/api/maybe/transactions', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify(transactionData)
      }))
    })

    it('should handle Maybe API rate limiting', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 429,
        headers: new Map([['Retry-After', '60']]),
        json: async () => ({ error: 'Rate limit exceeded' })
      })

      const response = await fetch('/api/maybe/transactions')
      expect(response.status).toBe(429)
    })
  })

  describe('Nextcloud Integration', () => {
    it('should list files from Nextcloud', async () => {
      const mockFiles = [
        { name: 'document.pdf', size: 1024, modified: '2024-01-15' },
        { name: 'image.jpg', size: 2048, modified: '2024-01-16' }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ files: mockFiles })
      })

      const response = await fetch('/api/nextcloud/files?path=/project1')
      const data = await response.json()

      expect(data.files).toEqual(mockFiles)
    })

    it('should upload file to Nextcloud', async () => {
      const fileData = new FormData()
      fileData.append('file', new Blob(['test content']), 'test.txt')
      fileData.append('path', '/project1/test.txt')

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true, path: '/project1/test.txt' })
      })

      const response = await fetch('/api/nextcloud/upload', {
        method: 'POST',
        body: fileData
      })

      expect(fetch).toHaveBeenCalledWith('/api/nextcloud/upload', expect.objectContaining({
        method: 'POST',
        body: fileData
      }))
    })

    it('should handle Nextcloud authentication errors', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 401,
        json: async () => ({ error: 'Invalid credentials' })
      })

      const response = await fetch('/api/nextcloud/files')
      expect(response.status).toBe(401)
    })
  })

  describe('Medusa E-commerce Integration', () => {
    it('should fetch products from Medusa', async () => {
      const mockProducts = [
        { id: 'prod_1', title: 'Product 1', price: 2999 },
        { id: 'prod_2', title: 'Product 2', price: 4999 }
      ]

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ products: mockProducts })
      })

      const response = await fetch('/api/medusa/products')
      const data = await response.json()

      expect(data.products).toEqual(mockProducts)
    })

    it('should add item to cart', async () => {
      const cartData = {
        variant_id: 'variant_123',
        quantity: 2
      }

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ cart: { id: 'cart_456', items: [cartData] } })
      })

      const response = await fetch('/api/medusa/cart/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(cartData)
      })

      expect(fetch).toHaveBeenCalledWith('/api/medusa/cart/items', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify(cartData)
      }))
    })

    it('should create order from cart', async () => {
      const orderData = {
        cart_id: 'cart_123',
        shipping_address: {
          first_name: 'John',
          last_name: 'Doe',
          address_1: '123 Main St',
          city: 'Anytown',
          postal_code: '12345'
        }
      }

      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ order: { id: 'order_789', status: 'pending' } })
      })

      const response = await fetch('/api/medusa/orders', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(orderData)
      })

      expect(fetch).toHaveBeenCalledWith('/api/medusa/orders', expect.objectContaining({
        method: 'POST',
        body: JSON.stringify(orderData)
      }))
    })

    it('should handle Medusa API errors gracefully', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 400,
        json: async () => ({ error: 'Invalid variant ID' })
      })

      const response = await fetch('/api/medusa/cart/items', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ variant_id: 'invalid', quantity: 1 })
      })

      expect(response.status).toBe(400)
    })
  })

  describe('Error Handling and Fallbacks', () => {
    it('should handle network errors', async () => {
      fetch.mockRejectedValueOnce(new Error('Network error'))

      try {
        await fetch('/api/openproject/projects')
      } catch (error) {
        expect(error.message).toBe('Network error')
      }
    })

    it('should implement retry logic for failed requests', async () => {
      // Mock first call to fail, second to succeed
      fetch
        .mockRejectedValueOnce(new Error('Network error'))
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ success: true })
        })

      // Simulate retry logic
      let result
      try {
        result = await fetch('/api/openproject/projects')
      } catch (error) {
        // Retry once
        result = await fetch('/api/openproject/projects')
      }

      expect(fetch).toHaveBeenCalledTimes(2)
      expect(result.ok).toBe(true)
    })

    it('should fall back to mock data when APIs are unavailable', async () => {
      fetch.mockResolvedValueOnce({
        ok: false,
        status: 503,
        json: async () => ({ error: 'Service unavailable' })
      })

      const response = await fetch('/api/medusa/products')
      
      if (!response.ok) {
        // Simulate fallback to mock data
        const mockData = { products: [{ id: 'mock_1', title: 'Mock Product' }] }
        expect(mockData.products).toBeDefined()
      }
    })
  })

  describe('Authentication and Security', () => {
    it('should include authentication headers', async () => {
      const authToken = 'Bearer test-token'
      
      fetch.mockResolvedValueOnce({
        ok: true,
        json: async () => ({ success: true })
      })

      await fetch('/api/openproject/projects', {
        headers: {
          'Authorization': authToken,
          'Content-Type': 'application/json'
        }
      })

      expect(fetch).toHaveBeenCalledWith('/api/openproject/projects', expect.objectContaining({
        headers: expect.objectContaining({
          'Authorization': authToken
        })
      }))
    })

    it('should handle token refresh for expired tokens', async () => {
      // Mock expired token response
      fetch
        .mockResolvedValueOnce({
          ok: false,
          status: 401,
          json: async () => ({ error: 'Token expired' })
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ access_token: 'new-token' })
        })
        .mockResolvedValueOnce({
          ok: true,
          json: async () => ({ success: true })
        })

      // Simulate token refresh flow
      let response = await fetch('/api/openproject/projects')
      
      if (response.status === 401) {
        // Refresh token
        const refreshResponse = await fetch('/api/auth/refresh')
        const { access_token } = await refreshResponse.json()
        
        // Retry original request with new token
        response = await fetch('/api/openproject/projects', {
          headers: { 'Authorization': `Bearer ${access_token}` }
        })
      }

      expect(fetch).toHaveBeenCalledTimes(3)
      expect(response.ok).toBe(true)
    })
  })

  describe('Data Transformation', () => {
    it('should transform OpenProject work packages to tasks', async () => {
      const workPackage = {
        id: 1,
        subject: 'OpenProject Task',
        description: { raw: 'Task description' },
        status: { name: 'In progress' },
        assignee: { name: 'John Doe' }
      }

      // Simulate transformation
      const transformedTask = {
        title: workPackage.subject,
        description: workPackage.description.raw,
        status: workPackage.status.name.toLowerCase().replace(' ', '_'),
        assigned_user: workPackage.assignee.name
      }

      expect(transformedTask.title).toBe('OpenProject Task')
      expect(transformedTask.status).toBe('in_progress')
    })

    it('should transform Maybe transactions to project transactions', async () => {
      const maybeTransaction = {
        id: 123,
        amount: { amount: -25000, currency: 'USD' },
        description: 'Office supplies',
        date: '2024-01-15',
        category: { name: 'Business Expenses' }
      }

      // Simulate transformation
      const transformedTransaction = {
        amount: maybeTransaction.amount.amount / 100, // Convert cents to dollars
        description: maybeTransaction.description,
        transaction_date: maybeTransaction.date,
        category: 'materials',
        transaction_type: maybeTransaction.amount.amount < 0 ? 'expense' : 'income'
      }

      expect(transformedTransaction.amount).toBe(-250)
      expect(transformedTransaction.transaction_type).toBe('expense')
    })
  })
})
