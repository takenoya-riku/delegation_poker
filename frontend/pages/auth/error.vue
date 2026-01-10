<template>
  <div class="container mx-auto px-4 py-8">
    <div class="max-w-md mx-auto text-center space-y-4">
      <div class="text-lg text-red-600">{{ errorMessage }}</div>
      <NuxtLink to="/" class="btn btn-primary">ホームに戻る</NuxtLink>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: '認証エラー - Delegation Poker'
})

const route = useRoute()
const errorMessage = computed(() => {
  const message = route.query.message as string | undefined
  return message || '認証中にエラーが発生しました'
})
</script>
