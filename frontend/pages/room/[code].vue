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

      <!-- フェーズに応じたコンポーネントを表示 -->
      <div v-if="hasDraftTopics">
        <TopicDraftList
          :topics="room.topics"
          :room-id="room.id"
          @refresh="refetch()"
        />
      </div>

      <div v-else-if="hasOrganizingTopics">
        <TopicOrganizeView
          :topics="room.topics"
          @refresh="refetch()"
        />
      </div>

      <div v-else>
        <TopicCard
          v-for="topic in votingTopics"
          :key="topic.id"
          :topic="topic"
          :participant-id="currentParticipantId"
          :total-participants="room.participants.length"
          @refresh="refetch()"
        />
      </div>
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

const hasDraftTopics = computed(() => {
  return room.value?.topics.some(t => t.status === 'draft') || false
})

const hasOrganizingTopics = computed(() => {
  return room.value?.topics.some(t => t.status === 'organizing') || false
})

const votingTopics = computed(() => {
  if (!room.value) return []
  return room.value.topics.filter(t => 
    ['current_voting', 'current_revealed', 'desired_voting', 'desired_revealed', 'completed'].includes(t.status)
  )
})

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

