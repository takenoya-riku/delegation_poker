import { fileURLToPath, URL } from 'node:url'
import { defineConfig, type UserConfig } from 'vitest/config'
import vue from '@vitejs/plugin-vue'

const vuePlugin = vue() as unknown as NonNullable<UserConfig['plugins']>[number]

export default defineConfig({
  plugins: [vuePlugin],
  resolve: {
    alias: {
      '~': fileURLToPath(new URL('./', import.meta.url)),
      '@': fileURLToPath(new URL('./', import.meta.url)),
    },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    include: ['tests/**/*.spec.ts'],
    setupFiles: ['tests/setup.ts'],
  },
})
