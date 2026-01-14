import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import type { Preview } from '@storybook/vue3'
import '../assets/css/main.css'

Object.assign(globalThis, {
  computed,
  onBeforeUnmount,
  onMounted,
  ref,
  watch,
  navigateTo: () => Promise.resolve(),
  useHead: () => undefined,
  useRoute: () => ({ params: {} }),
})

const preview: Preview = {
  parameters: {
    controls: { expanded: true },
  },
}

export default preview
