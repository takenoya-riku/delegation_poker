<template>
  <div class="container mx-auto px-4 py-8">
    <div v-if="fetching" class="text-center">
      <span class="loading loading-spinner loading-lg"></span>
    </div>
    <div v-else-if="error" class="alert alert-error">
      <span>エラー: {{ error.message }}</span>
    </div>
    <div v-else-if="room" class="space-y-6">
      <div class="card bg-base-100 shadow-xl">
        <div class="card-body">
          <h1 class="card-title text-2xl">{{ room.name }}</h1>
          <p class="text-sm text-gray-500">ルームコード: {{ room.code }}</p>
        </div>
      </div>

      <ParticipantList :participants="room.participants" />

      <TopicList
        :topics="room.topics"
        :room-id="room.id"
        :participant-id="currentParticipantId"
        @refresh="refetch()"
      />
    </div>
  </div>
</template>

<script setup lang="ts">
import { useQuery } from '@urql/vue'
import { RoomDocument } from '~/graphql/generated/types'

const route = useRoute()
const code = route.params.code as string

const { data, fetching, error, refetch } = useQuery({
  query: RoomDocument,
  variables: { code: code.toUpperCase() },
  requestPolicy: 'cache-and-network',
  pollInterval: 5000 // 5秒ごとにポーリング
})

const room = computed(() => data.value?.room)

// ローカルストレージから参加者IDを取得（簡易実装）
const currentParticipantId = ref<string | null>(null)

onMounted(() => {
  if (typeof window !== 'undefined') {
    currentParticipantId.value = localStorage.getItem(`participant_${code.toUpperCase()}`)
  }
})

useHead({
  title: room.value ? `${room.value.name} - Delegation Poker` : 'Delegation Poker'
})
</script>
