<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-pink-50">
    <div class="container mx-auto px-4 py-8">
      <div v-if="fetching" class="flex items-center justify-center min-h-screen">
        <div class="text-center">
          <span class="loading loading-spinner loading-lg text-purple-500"></span>
          <p class="mt-4 text-gray-600">読み込み中...</p>
        </div>
      </div>
      <div v-else-if="error" class="card-modern border-2 border-red-200 animate-fade-in">
        <div class="card-body">
          <div class="alert alert-error shadow-lg">
            <span>エラー: {{ error.message }}</span>
          </div>
        </div>
      </div>
      <div v-else-if="room" class="space-y-8 animate-fade-in">
        <!-- ルームヘッダー -->
        <div class="card-modern border-2 border-purple-200 bg-gradient-to-r from-white to-purple-50 shadow-xl">
          <div class="card-body p-6">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-4xl font-bold text-gradient mb-2">{{ room.name }}</h1>
                <div class="flex items-center gap-3">
                  <span class="badge badge-lg badge-primary px-4 py-2 text-sm font-semibold">
                    🔑 ルームコード: {{ room.code }}
                  </span>
                  <span class="text-sm text-gray-600">
                    👥 {{ room.participants.length }}人が参加中
                  </span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 参加者リスト -->
        <ParticipantList :participants="room.participants" />

        <!-- フェーズに応じたコンポーネントを表示 -->
        <div v-if="hasDraftTopics" class="animate-fade-in" style="animation-delay: 0.1s">
          <TopicDraftList
            :topics="room.topics"
            :room-id="room.id"
            @refresh="refetch()"
          />
        </div>

        <div v-else-if="hasOrganizingTopics" class="animate-fade-in" style="animation-delay: 0.1s">
          <TopicOrganizeView
            :topics="room.topics"
            @refresh="refetch()"
          />
        </div>

        <div v-else class="space-y-6 animate-fade-in" style="animation-delay: 0.1s">
          <TopicCard
            v-for="(topic, index) in votingTopics"
            :key="topic.id"
            :topic="topic"
            :participant-id="currentParticipantId"
            :total-participants="room.participants.length"
            :style="{ animationDelay: `${0.1 + index * 0.05}s` }"
            @refresh="refetch()"
          />
        </div>
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

