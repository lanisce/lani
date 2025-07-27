// Vitest setup file
import { vi } from 'vitest'
import { afterEach, beforeAll } from 'vitest'

// Global test setup
beforeAll(() => {
  // Mock window.matchMedia for responsive components
  Object.defineProperty(window, 'matchMedia', {
    writable: true,
    value: vi.fn().mockImplementation(query => ({
      matches: false,
      media: query,
      onchange: null,
      addListener: vi.fn(), // deprecated
      removeListener: vi.fn(), // deprecated
      addEventListener: vi.fn(),
      removeEventListener: vi.fn(),
      dispatchEvent: vi.fn(),
    })),
  })

  // Mock IntersectionObserver
  global.IntersectionObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }))

  // Mock ResizeObserver
  global.ResizeObserver = vi.fn().mockImplementation(() => ({
    observe: vi.fn(),
    unobserve: vi.fn(),
    disconnect: vi.fn(),
  }))

  // Mock fetch for API calls
  global.fetch = vi.fn()

  // Mock Rails UJS and Turbo
  global.Rails = {
    fire: vi.fn(),
    ajax: vi.fn(),
  }

  global.Turbo = {
    visit: vi.fn(),
    cache: {
      clear: vi.fn(),
    },
  }
})

// Cleanup after each test
afterEach(() => {
  vi.clearAllMocks()
})
