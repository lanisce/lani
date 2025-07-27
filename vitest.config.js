import { defineConfig } from 'vitest/config'
import { resolve } from 'path'

export default defineConfig({
  test: {
    globals: true,
    environment: 'jsdom',
    setupFiles: ['./test/setup.js'],
    include: ['test/**/*.{test,spec}.{js,mjs,cjs,ts,mts,cts,jsx,tsx}'],
    exclude: ['node_modules', 'dist', 'cypress'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: [
        'node_modules/',
        'test/',
        'cypress/',
        '**/*.config.js',
        '**/*.config.ts'
      ]
    }
  },
  resolve: {
    alias: {
      '@': resolve(__dirname, './app/javascript'),
      '~': resolve(__dirname, './app/assets')
    }
  }
})
