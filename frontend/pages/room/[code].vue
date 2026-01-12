<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-pink-50">
    <div class="container mx-auto px-4 py-8">
      <div v-if="fetching && !hasLoaded" class="flex items-center justify-center min-h-screen">
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
              <div class="flex items-center gap-3">
                <button
                  v-if="isRoomMaster"
                  class="btn btn-sm px-4 py-2 rounded-lg bg-gradient-to-r from-red-500 to-pink-500 text-white border-0 hover:from-red-600 hover:to-pink-600 transition-all duration-300 shadow-md hover:shadow-lg"
                  :disabled="deletingRoom"
                  @click="handleDeleteRoom"
                >
                  <span v-if="deletingRoom" class="loading loading-spinner loading-xs mr-1"></span>
                  ルームを削除
                </button>
              </div>
            </div>
            <div v-if="deleteError" class="alert alert-error mt-4 shadow-md animate-fade-in">
              <span>{{ deleteError }}</span>
            </div>
          </div>
        </div>

        <!-- 参加者リスト -->
        <ParticipantList :participants="room.participants" :current-participant-id="currentParticipantId" />

        <!-- フェーズに応じたコンポーネントを表示 -->
        <!-- トピックが1つもない場合、またはdraftトピックがある場合に対象出しフォームを表示 -->
        <div v-if="hasNoTopics || hasDraftTopics" class="animate-fade-in" style="animation-delay: 0.1s">
          <TopicDraftList
            :topics="room.topics"
            :room-id="room.id"
            :is-room-master="isRoomMaster"
            @refresh="handleRefresh"
          />
        </div>

        <div v-else-if="hasOrganizingTopics" class="animate-fade-in" style="animation-delay: 0.1s">
          <TopicOrganizeView
            :topics="room.topics"
            :is-room-master="isRoomMaster"
            @refresh="handleRefresh"
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
            @refresh="handleRefresh"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation, useQuery } from '@urql/vue'
import { DeleteRoomDocument, RoomDocument } from '~/graphql/generated/types'

const route = useRoute()
const code = route.params.code as string

const { data, fetching, error, executeQuery } = useQuery({
  query: RoomDocument,
  variables: { code: code.toUpperCase() },
  requestPolicy: 'cache-and-network'
})

const room = computed(() => data.value?.room)
const hasLoaded = ref(false)
const savedRoomsKey = 'saved_rooms'
const deleteError = ref('')
const deletingRoom = ref(false)

const handleRefresh = () => {
  executeQuery({ requestPolicy: 'network-only' })
}

const deleteRoomMutation = useMutation(DeleteRoomDocument)

const removeSavedRoom = (roomCode: string) => {
  if (typeof window === 'undefined') return
  const raw = localStorage.getItem(savedRoomsKey)
  const parsed = raw ? JSON.parse(raw) : []
  const rooms = Array.isArray(parsed) ? parsed : []
  const filtered = rooms.filter((entry: { code: string }) => entry.code !== roomCode)
  localStorage.setItem(savedRoomsKey, JSON.stringify(filtered))
}

const handleDeleteRoom = async () => {
  if (!room.value || !currentParticipantId.value) return
  if (!confirm('このルームを削除しますか？この操作は取り消せません。')) return

  deletingRoom.value = true
  deleteError.value = ''

  const result = await deleteRoomMutation.executeMutation({
    roomId: room.value.id,
    participantId: currentParticipantId.value,
  })

  if (result.data?.deleteRoom?.success) {
    const upperCode = room.value.code.toUpperCase()
    removeSavedRoom(upperCode)
    if (typeof window !== 'undefined') {
      localStorage.removeItem(`participant_${upperCode}`)
      localStorage.removeItem(`room_master_${upperCode}`)
      sessionStorage.removeItem(`participant_session_${upperCode}`)
    }
    await navigateTo('/')
  } else {
    deleteError.value = result.data?.deleteRoom?.errors?.[0] || 'ルームの削除に失敗しました'
  }

  deletingRoom.value = false
}

let pollTimer: ReturnType<typeof setInterval> | null = null

const hasNoTopics = computed(() => {
  return !room.value?.topics || room.value.topics.length === 0
})

const hasDraftTopics = computed(() => {
  return room.value?.topics.some(t => t.status === 'DRAFT' || t.status === 'draft') || false
})

const hasOrganizingTopics = computed(() => {
  return room.value?.topics.some(t => t.status === 'ORGANIZING' || t.status === 'organizing') || false
})

const votingTopics = computed(() => {
  if (!room.value) return []
  return room.value.topics.filter(t => {
    const status = t.status.toUpperCase()
    return ['CURRENT_VOTING', 'CURRENT_REVEALED', 'DESIRED_VOTING', 'DESIRED_REVEALED', 'COMPLETED'].includes(status) ||
           ['current_voting', 'current_revealed', 'desired_voting', 'desired_revealed', 'completed'].includes(t.status)
  })
})

// ローカルストレージから参加者IDを取得（簡易実装）
const currentParticipantId = ref<string | null>(null)
const roomMasterId = ref<string | null>(null)

watch(
  () => room.value,
  (value) => {
    if (!value) return
    hasLoaded.value = true

    if (typeof window !== 'undefined') {
      const raw = localStorage.getItem(savedRoomsKey)
      const parsed = raw ? JSON.parse(raw) : []
      const rooms = Array.isArray(parsed) ? parsed : []
      const now = new Date().toISOString()
      const existingIndex = rooms.findIndex((entry: { code: string }) => entry.code === value.code)
      const updatedEntry = { code: value.code, name: value.name, updatedAt: now }

      if (existingIndex >= 0) {
        rooms.splice(existingIndex, 1, updatedEntry)
      } else {
        rooms.push(updatedEntry)
      }

      localStorage.setItem(savedRoomsKey, JSON.stringify(rooms))
    }
  },
  { immediate: true }
)

onMounted(() => {
  if (typeof window !== 'undefined') {
    const upperCode = code.toUpperCase()
    currentParticipantId.value =
      sessionStorage.getItem(`participant_session_${upperCode}`) ||
      localStorage.getItem(`participant_${upperCode}`)
    roomMasterId.value = localStorage.getItem(`room_master_${upperCode}`)
  }

  pollTimer = setInterval(() => {
    executeQuery({ requestPolicy: 'network-only' })
  }, 5000)
})

const isRoomMaster = computed(() => {
  return Boolean(currentParticipantId.value && roomMasterId.value && currentParticipantId.value === roomMasterId.value)
})

onBeforeUnmount(() => {
  if (pollTimer) {
    clearInterval(pollTimer)
    pollTimer = null
  }
})

useHead({
  title: room.value ? `${room.value.name} - Delegation Poker` : 'Delegation Poker'
})
</script>
