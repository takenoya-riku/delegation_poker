import { fileURLToPath } from 'node:url'
import tailwindcss from 'tailwindcss'
import autoprefixer from 'autoprefixer'

const tailwindConfigPath = fileURLToPath(new URL('./tailwind.config.js', import.meta.url))

export default {
  plugins: [
    tailwindcss({ config: tailwindConfigPath }),
    autoprefixer(),
  ],
}
