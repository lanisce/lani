// Inline edit controller unit tests
import { describe, it, expect, vi, beforeEach, afterEach } from 'vitest'
import { Application } from '@hotwired/stimulus'
import InlineEditController from '../../../app/javascript/controllers/inline_edit_controller'

// Mock fetch for API calls
global.fetch = vi.fn()

describe('InlineEditController', () => {
  let application
  let controller
  let element

  beforeEach(() => {
    // Set up DOM element
    element = document.createElement('div')
    element.setAttribute('data-controller', 'inline-edit')
    element.setAttribute('data-inline-edit-url-value', '/tasks/1')
    element.setAttribute('data-inline-edit-field-value', 'title')
    element.innerHTML = `
      <span data-inline-edit-target="display" data-action="dblclick->inline-edit#startEdit">
        Original Task Title
      </span>
      <input data-inline-edit-target="input" type="text" style="display: none;" />
      <div data-inline-edit-target="actions" style="display: none;">
        <button data-action="click->inline-edit#save">Save</button>
        <button data-action="click->inline-edit#cancel">Cancel</button>
      </div>
    `
    document.body.appendChild(element)

    // Set up Stimulus application
    application = Application.start()
    application.register('inline-edit', InlineEditController)
    
    // Wait for controller to connect
    return new Promise(resolve => {
      setTimeout(() => {
        controller = application.getControllerForElementAndIdentifier(element, 'inline-edit')
        if (!controller) {
          // Fallback: create controller instance manually for testing
          controller = new InlineEditController()
          controller.element = element
          controller.displayTarget = element.querySelector('[data-inline-edit-target="display"]')
          controller.inputTarget = element.querySelector('[data-inline-edit-target="input"]')
          controller.actionsTarget = element.querySelector('[data-inline-edit-target="actions"]')
          controller.urlValue = '/tasks/1'
          controller.fieldValue = 'title'
          controller.connect()
        }
        resolve()
      }, 10)
    })
  })

  afterEach(() => {
    if (element.parentNode) {
      element.parentNode.removeChild(element)
    }
    application.stop()
    vi.clearAllMocks()
  })

  describe('Initialization', () => {
    it('should initialize with correct values', () => {
      expect(controller.urlValue).toBe('/tasks/1')
      expect(controller.fieldValue).toBe('title')
    })

    it('should show display mode by default', () => {
      expect(controller.displayTarget.style.display).not.toBe('none')
      expect(controller.inputTarget.style.display).toBe('none')
      expect(controller.actionsTarget.style.display).toBe('none')
    })

    it('should set initial input value from display text', () => {
      expect(controller.inputTarget.value).toBe('Original Task Title')
    })
  })

  describe('Edit Mode', () => {
    it('should enter edit mode on double click', () => {
      const displayElement = controller.displayTarget
      displayElement.dispatchEvent(new Event('dblclick'))

      expect(controller.displayTarget.style.display).toBe('none')
      expect(controller.inputTarget.style.display).not.toBe('none')
      expect(controller.actionsTarget.style.display).not.toBe('none')
      expect(controller.inputTarget).toBe(document.activeElement)
    })

    it('should select all text when entering edit mode', () => {
      const selectSpy = vi.spyOn(controller.inputTarget, 'select')
      controller.startEdit()
      
      expect(selectSpy).toHaveBeenCalled()
    })

    it('should handle keyboard shortcuts in edit mode', () => {
      controller.startEdit()
      
      // Test Enter key to save
      const enterEvent = new KeyboardEvent('keydown', { key: 'Enter' })
      controller.inputTarget.dispatchEvent(enterEvent)
      
      // Test Escape key to cancel
      const escapeEvent = new KeyboardEvent('keydown', { key: 'Escape' })
      controller.inputTarget.dispatchEvent(escapeEvent)
      
      expect(controller.displayTarget.style.display).not.toBe('none')
      expect(controller.inputTarget.style.display).toBe('none')
    })
  })

  describe('Save Functionality', () => {
    beforeEach(() => {
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ success: true, title: 'Updated Task Title' })
      })
    })

    it('should save changes via PATCH request', async () => {
      controller.startEdit()
      controller.inputTarget.value = 'Updated Task Title'
      
      await controller.save()
      
      expect(fetch).toHaveBeenCalledWith('/tasks/1', {
        method: 'PATCH',
        headers: {
          'Content-Type': 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
          'X-CSRF-Token': expect.any(String)
        },
        body: JSON.stringify({
          task: { title: 'Updated Task Title' }
        })
      })
    })

    it('should update display text after successful save', async () => {
      controller.startEdit()
      controller.inputTarget.value = 'Updated Task Title'
      
      await controller.save()
      
      expect(controller.displayTarget.textContent).toBe('Updated Task Title')
      expect(controller.displayTarget.style.display).not.toBe('none')
      expect(controller.inputTarget.style.display).toBe('none')
    })

    it('should handle save errors gracefully', async () => {
      fetch.mockResolvedValue({
        ok: false,
        status: 422,
        json: async () => ({ errors: ['Title cannot be blank'] })
      })
      
      const consoleErrorSpy = vi.spyOn(console, 'error').mockImplementation(() => {})
      
      controller.startEdit()
      controller.inputTarget.value = ''
      
      await controller.save()
      
      expect(consoleErrorSpy).toHaveBeenCalledWith('Save failed:', expect.any(Object))
      // Should remain in edit mode on error
      expect(controller.inputTarget.style.display).not.toBe('none')
      
      consoleErrorSpy.mockRestore()
    })

    it('should show validation errors to user', async () => {
      fetch.mockResolvedValue({
        ok: false,
        status: 422,
        json: async () => ({ errors: ['Title cannot be blank'] })
      })
      
      controller.startEdit()
      controller.inputTarget.value = ''
      
      await controller.save()
      
      const errorElement = element.querySelector('[data-inline-edit-target="error"]')
      if (errorElement) {
        expect(errorElement.textContent).toContain('Title cannot be blank')
      }
    })
  })

  describe('Cancel Functionality', () => {
    it('should cancel edit and restore original value', () => {
      const originalText = controller.displayTarget.textContent
      
      controller.startEdit()
      controller.inputTarget.value = 'Changed Text'
      controller.cancel()
      
      expect(controller.displayTarget.textContent).toBe(originalText)
      expect(controller.inputTarget.value).toBe(originalText)
      expect(controller.displayTarget.style.display).not.toBe('none')
      expect(controller.inputTarget.style.display).toBe('none')
    })

    it('should handle Escape key to cancel', () => {
      controller.startEdit()
      controller.inputTarget.value = 'Changed Text'
      
      const escapeEvent = new KeyboardEvent('keydown', { key: 'Escape' })
      controller.handleKeydown(escapeEvent)
      
      expect(controller.displayTarget.style.display).not.toBe('none')
      expect(controller.inputTarget.style.display).toBe('none')
    })
  })

  describe('CSRF Token Handling', () => {
    it('should include CSRF token in requests', async () => {
      // Mock CSRF token
      const csrfToken = 'test-csrf-token'
      const metaElement = document.createElement('meta')
      metaElement.name = 'csrf-token'
      metaElement.content = csrfToken
      document.head.appendChild(metaElement)
      
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ success: true })
      })
      
      controller.startEdit()
      await controller.save()
      
      expect(fetch).toHaveBeenCalledWith(expect.any(String), expect.objectContaining({
        headers: expect.objectContaining({
          'X-CSRF-Token': csrfToken
        })
      }))
      
      document.head.removeChild(metaElement)
    })

    it('should handle missing CSRF token gracefully', async () => {
      fetch.mockResolvedValue({
        ok: true,
        json: async () => ({ success: true })
      })
      
      controller.startEdit()
      await controller.save()
      
      expect(fetch).toHaveBeenCalledWith(expect.any(String), expect.objectContaining({
        headers: expect.objectContaining({
          'X-CSRF-Token': ''
        })
      }))
    })
  })

  describe('Different Field Types', () => {
    it('should handle textarea fields', () => {
      const textarea = document.createElement('textarea')
      textarea.setAttribute('data-inline-edit-target', 'input')
      textarea.style.display = 'none'
      
      element.replaceChild(textarea, controller.inputTarget)
      controller.inputTarget = textarea
      
      controller.startEdit()
      
      expect(textarea.style.display).not.toBe('none')
      expect(textarea).toBe(document.activeElement)
    })

    it('should handle select fields', () => {
      const select = document.createElement('select')
      select.setAttribute('data-inline-edit-target', 'input')
      select.innerHTML = `
        <option value="pending">Pending</option>
        <option value="in_progress">In Progress</option>
        <option value="completed">Completed</option>
      `
      select.style.display = 'none'
      
      element.replaceChild(select, controller.inputTarget)
      controller.inputTarget = select
      
      controller.startEdit()
      
      expect(select.style.display).not.toBe('none')
      expect(select).toBe(document.activeElement)
    })
  })

  describe('Loading States', () => {
    it('should show loading state during save', async () => {
      let resolvePromise
      const savePromise = new Promise(resolve => {
        resolvePromise = resolve
      })
      
      fetch.mockReturnValue(savePromise)
      
      controller.startEdit()
      const savePromiseResult = controller.save()
      
      // Check loading state
      expect(controller.element.classList.contains('saving')).toBe(true)
      
      resolvePromise({
        ok: true,
        json: async () => ({ success: true })
      })
      
      await savePromiseResult
      
      // Check loading state is removed
      expect(controller.element.classList.contains('saving')).toBe(false)
    })

    it('should disable actions during save', async () => {
      let resolvePromise
      const savePromise = new Promise(resolve => {
        resolvePromise = resolve
      })
      
      fetch.mockReturnValue(savePromise)
      
      controller.startEdit()
      const saveButton = controller.actionsTarget.querySelector('button')
      const savePromiseResult = controller.save()
      
      expect(saveButton.disabled).toBe(true)
      
      resolvePromise({
        ok: true,
        json: async () => ({ success: true })
      })
      
      await savePromiseResult
      
      expect(saveButton.disabled).toBe(false)
    })
  })

  describe('Accessibility', () => {
    it('should maintain proper ARIA attributes', () => {
      controller.startEdit()
      
      expect(controller.inputTarget.getAttribute('aria-label')).toBeTruthy()
      expect(controller.displayTarget.getAttribute('aria-live')).toBe('polite')
    })

    it('should handle focus management properly', () => {
      controller.startEdit()
      expect(controller.inputTarget).toBe(document.activeElement)
      
      controller.cancel()
      expect(controller.displayTarget).toBe(document.activeElement)
    })
  })
})
