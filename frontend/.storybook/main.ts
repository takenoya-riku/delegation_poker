import path from 'node:path'
import { fileURLToPath } from 'node:url'
import type { StorybookConfig } from '@storybook/vue3-vite'
import autoprefixer from 'autoprefixer'
import tailwindcss from 'tailwindcss'
import vue from '@vitejs/plugin-vue'
import type { UserConfig } from 'vite'

const projectRoot = fileURLToPath(new URL('../', import.meta.url))
const urqlMockPath = fileURLToPath(new URL('./mocks/urql.ts', import.meta.url))
const storyGlob = path.resolve(projectRoot, 'components/**/*.stories.@(js|jsx|ts|tsx|mdx)')
const tailwindConfigPath = fileURLToPath(new URL('../tailwind.config.js', import.meta.url))

const config: StorybookConfig = {
  stories: [storyGlob],
  addons: ['@storybook/addon-essentials'],
  framework: {
    name: '@storybook/vue3-vite',
    options: {},
  },
  viteFinal: async (viteConfig: UserConfig) => {
    const alias = viteConfig.resolve?.alias ?? {}

    return {
      ...viteConfig,
      root: projectRoot,
      plugins: [...(viteConfig.plugins ?? []), vue()],
      css: {
        ...viteConfig.css,
        postcss: {
          plugins: [tailwindcss({ config: tailwindConfigPath }), autoprefixer()],
        },
      },
      server: {
        ...viteConfig.server,
        fs: {
          ...viteConfig.server?.fs,
          allow: [projectRoot],
          strict: false,
        },
      },
      resolve: {
        ...viteConfig.resolve,
        alias: {
          ...alias,
          '~': projectRoot,
          '@': projectRoot,
          '@urql/vue': urqlMockPath,
        },
      },
    }
  },
}

export default config
