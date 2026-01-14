import { computed, onBeforeUnmount, onMounted, ref, watch } from 'vue'
import { vi } from 'vitest'

const globals = {
  computed,
  onBeforeUnmount,
  onMounted,
  ref,
  useHead: vi.fn(),
  useRoute: () => ({ params: {} }),
  watch,
}

Object.assign(globalThis, globals)
