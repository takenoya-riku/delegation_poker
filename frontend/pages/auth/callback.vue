<template>
  <div class="container mx-auto px-4 py-8">
    <div class="max-w-md mx-auto text-center">
      <div v-if="loading" class="space-y-4">
        <div class="text-lg">認証処理中...</div>
        <div class="loading loading-spinner loading-lg"></div>
      </div>
      <div v-else-if="error" class="space-y-4">
        <div class="text-lg text-red-600">{{ error }}</div>
        <NuxtLink to="/" class="btn btn-primary">ホームに戻る</NuxtLink>
      </div>
      <div v-else class="space-y-4">
        <div class="text-lg text-green-600">認証が完了しました</div>
        <NuxtLink to="/" class="btn btn-primary">ホームに戻る</NuxtLink>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
useHead({
  title: '認証コールバック - Delegation Poker'
})

const route = useRoute()
const router = useRouter()
const { setToken } = useAuth()

const loading = ref(true)
const error = ref<string | null>(null)

onMounted(() => {
  const token = route.query.token as string | undefined
  
  if (token) {
    setToken(token)
    loading.value = false
    // トークンを設定後、少し待ってからリダイレクト
    setTimeout(() => {
      router.push('/')
    }, 1000)
  } else {
    error.value = 'トークンが取得できませんでした'
    loading.value = false
  }
})
</script>
