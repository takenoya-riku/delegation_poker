<template>
  <div class="min-h-screen relative overflow-hidden">
    <div class="absolute inset-0 bg-gradient-to-br from-blue-400 via-teal-300 to-yellow-200 opacity-20" />
    <div class="absolute inset-0 bg-[url('data:image/svg+xml;base64,PHN2ZyB3aWR0aD0iNjAiIGhlaWdodD0iNjAiIHZpZXdCb3g9IjAgMCA2MCA2MCIgeG1sbnM9Imh0dHA6Ly93d3cudzMub3JnLzIwMDAvc3ZnIj48ZyBmaWxsPSJub25lIiBmaWxsLXJ1bGU9ImV2ZW5vZGQiPjxnIGZpbGw9IiNmZmYiIGZpbGwtb3BhY2l0eT0iMC4wNiI+PHJlY3QgeD0iMjAiIHk9IjIwIiB3aWR0aD0iNCIgaGVpZ2h0PSI0Ii8+PC9nPjwvZz48L3N2Zz4=')] opacity-30" />

    <div class="container mx-auto px-4 py-8 relative z-10">
      <div class="flex items-center justify-between mb-10 animate-fade-in">
        <div>
          <h1 class="text-4xl font-bold text-gradient">
            保存したルーム
          </h1>
          <p class="text-gray-600 mt-2">
            以前開いたルームを一覧で確認できます
          </p>
        </div>
        <NuxtLink
          to="/"
          class="btn-gradient px-6 py-2 rounded-full text-sm font-semibold shadow-lg"
        >
          ホームに戻る
        </NuxtLink>
      </div>

      <div
        v-if="rooms.length === 0"
        class="card-modern border-2 border-dashed border-gray-300 bg-white/70 text-center py-16"
      >
        <span class="text-5xl mb-4 block">📭</span>
        <p class="text-gray-600 font-medium">
          まだ保存されたルームがありません
        </p>
        <p class="text-sm text-gray-500 mt-2">
          ルームに参加するとここに表示されます
        </p>
      </div>

      <div
        v-else
        class="grid gap-6 md:grid-cols-2"
      >
        <div
          v-for="room in rooms"
          :key="room.code"
          class="card-modern border-2 border-blue-100 bg-white/80 shadow-lg hover:shadow-xl transition-all duration-300"
        >
          <div class="card-body p-6">
            <h2 class="text-2xl font-bold text-gray-800">
              {{ room.name }}
            </h2>
            <div class="mt-3 flex items-center gap-3">
              <span class="badge badge-lg badge-primary px-4 py-2 text-sm font-semibold">
                🔑 {{ room.code }}
              </span>
              <span class="text-xs text-gray-500">最終訪問: {{ formatDate(room.updatedAt) }}</span>
            </div>
            <div class="mt-5">
              <NuxtLink
                :to="`/room/${room.code}`"
                class="btn-gradient-secondary px-6 py-2 rounded-full text-sm font-semibold"
              >
                ルームを開く
              </NuxtLink>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
type SavedRoom = {
  code: string
  name: string
  updatedAt: string
}

const rooms = ref<SavedRoom[]>([])
const savedRoomsKey = 'saved_rooms'

const loadRooms = () => {
  if (typeof window === 'undefined') return
  const raw = localStorage.getItem(savedRoomsKey)
  const parsed = raw ? JSON.parse(raw) : []
  const list = Array.isArray(parsed) ? parsed : []
  rooms.value = list
}

const formatDate = (value: string) => {
  if (!value) return '-'
  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return value
  return date.toLocaleString('ja-JP')
}

onMounted(() => {
  loadRooms()
  window.addEventListener('storage', loadRooms)
})

onBeforeUnmount(() => {
  if (typeof window !== 'undefined') {
    window.removeEventListener('storage', loadRooms)
  }
})

useHead({
  title: '保存したルーム - Delegation Poker'
})
</script>
