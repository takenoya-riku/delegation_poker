<template>
  <NuxtLink
    to="/"
    :class="buttonClass"
  >
    🏠 ホームへ戻る
  </NuxtLink>
</template>

<script setup lang="ts">
const props = withDefaults(defineProps<{
  variant?: 'outline' | 'gradient'
}>(), {
  variant: 'outline',
})

const buttonClass = computed(() => {
  if (props.variant === 'gradient') {
    return 'btn-gradient px-6 py-2 rounded-full text-sm font-semibold shadow-lg'
  }
  return 'btn px-4 py-2 rounded-lg font-semibold shadow-md border-2 border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-all duration-300'
})
</script>
