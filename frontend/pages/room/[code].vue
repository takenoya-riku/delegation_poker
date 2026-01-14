<template>
  <div class="min-h-screen bg-gradient-to-br from-purple-50 via-blue-50 to-pink-50">
    <div class="container mx-auto px-4 py-8">
      <div
        v-if="fetching && !hasLoaded"
        class="flex items-center justify-center min-h-screen"
      >
        <div class="text-center">
          <span class="loading loading-spinner loading-lg text-purple-500" />
          <p class="mt-4 text-gray-600">
            読み込み中...
          </p>
        </div>
      </div>
      <div
        v-else-if="error"
        class="card-modern border-2 border-red-200 animate-fade-in"
      >
        <div class="card-body">
          <div class="alert alert-error shadow-lg">
            <span>エラー: {{ error.message }}</span>
          </div>
        </div>
      </div>
      <div
        v-else-if="roomAccessError"
        class="card-modern border-2 border-red-200 animate-fade-in"
      >
        <div class="card-body">
          <div class="alert alert-error shadow-lg">
            <span>{{ roomAccessError }}</span>
          </div>
          <div class="mt-4 flex justify-end">
            <HomeBackButton variant="gradient" />
          </div>
        </div>
      </div>
      <div
        v-else-if="room"
        class="space-y-8 animate-fade-in"
      >
        <!-- ルームヘッダー -->
        <div class="card-modern border-2 border-purple-200 bg-gradient-to-r from-white to-purple-50 shadow-xl">
          <div class="card-body p-6">
            <div class="flex items-center justify-between">
              <div>
                <h1 class="text-4xl font-bold text-gradient mb-2">
                  {{ room.name }}
                </h1>
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
                <HomeBackButton />
                <button
                  v-if="isRoomMaster"
                  class="btn btn-sm px-4 py-2 rounded-lg bg-gradient-to-r from-red-500 to-pink-500 text-white border-0 hover:from-red-600 hover:to-pink-600 transition-all duration-300 shadow-md hover:shadow-lg"
                  :disabled="deletingRoom"
                  @click="handleDeleteRoom"
                >
                  <span
                    v-if="deletingRoom"
                    class="loading loading-spinner loading-xs mr-1"
                  />
                  ルームを削除
                </button>
              </div>
            </div>
            <div
              v-if="deleteError"
              class="alert alert-error mt-4 shadow-md animate-fade-in"
            >
              <span>{{ deleteError }}</span>
            </div>
            <div class="mt-6">
              <div class="flex items-center gap-3 mb-3">
                <span class="text-sm text-gray-600">現在のフロー:</span>
                <span
                  class="badge badge-lg px-4 py-2 text-sm font-semibold"
                  :class="currentPhaseBadgeClass"
                >
                  {{ currentPhaseLabel }}
                </span>
              </div>
              <div class="grid gap-3 sm:grid-cols-3">
                <div
                  class="flex items-center gap-3 rounded-xl border-2 px-4 py-3"
                  :class="phaseStepClass('draft')"
                >
                  <span class="text-xl">{{ phaseStepIcon('draft') }}</span>
                  <div>
                    <p class="text-sm font-semibold">
                      対象出し
                    </p>
                    <p class="text-xs text-gray-600">
                      話し合いたい内容を追加
                    </p>
                  </div>
                </div>
                <div
                  class="flex items-center gap-3 rounded-xl border-2 px-4 py-3"
                  :class="phaseStepClass('organizing')"
                >
                  <span class="text-xl">{{ phaseStepIcon('organizing') }}</span>
                  <div>
                    <p class="text-sm font-semibold">
                      整理
                    </p>
                    <p class="text-xs text-gray-600">
                      重複をまとめる
                    </p>
                  </div>
                </div>
                <div
                  class="flex items-center gap-3 rounded-xl border-2 px-4 py-3"
                  :class="phaseStepClass('voting')"
                >
                  <span class="text-xl">{{ phaseStepIcon('voting') }}</span>
                  <div>
                    <p class="text-sm font-semibold">
                      投票
                    </p>
                    <p class="text-xs text-gray-600">
                      現状/理想を評価
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>

        <!-- 参加者リスト -->
        <div class="space-y-3">
          <ParticipantList
            :participants="room.participants"
            :current-participant-id="currentParticipantId"
            :room-master-id="roomMasterId"
            :is-room-master="isRoomMaster"
            @remove="handleRemoveParticipant"
          />
          <div
            v-if="removeParticipantError"
            class="alert alert-error shadow-md animate-fade-in"
          >
            <span>{{ removeParticipantError }}</span>
          </div>
        </div>

        <!-- フェーズに応じたコンポーネントを表示 -->
        <!-- トピックが1つもない場合、またはdraftトピックがある場合に対象出しフォームを表示 -->
        <div
          v-if="hasNoTopics || hasDraftTopics"
          class="animate-fade-in"
          style="animation-delay: 0.1s"
        >
          <TopicDraftList
            :topics="room.topics"
            :room-id="room.id"
            :participants="room.participants"
            :is-room-master="isRoomMaster"
            :current-participant-id="currentParticipantId"
            @refresh="handleRefresh"
          />
        </div>

        <div
          v-else-if="hasOrganizingTopics"
          class="animate-fade-in"
          style="animation-delay: 0.1s"
        >
          <TopicOrganizeView
            :topics="room.topics"
            :participants="room.participants"
            :is-room-master="isRoomMaster"
            :current-participant-id="currentParticipantId"
            @refresh="handleRefresh"
          />
        </div>

        <div
          v-else
          class="space-y-6 animate-fade-in"
          style="animation-delay: 0.1s"
        >
          <VotingBoard
            :topics="votingTopics"
            :participants="room.participants"
            :participant-id="currentParticipantId"
            :total-participants="room.participants.length"
            :is-room-master="isRoomMaster"
            :team-name="room.name"
            @refresh="handleRefresh"
          />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation, useQuery } from '@urql/vue'
import { parse } from 'graphql'
import { DeleteRoomDocument, RoomDocument } from '~/graphql/generated/types'
import HomeBackButton from '~/components/ui/HomeBackButton.vue'

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
const roomAccessError = ref('')

const normalizeRoomCode = (roomCode: string) => roomCode.toUpperCase()

const removeSavedRoom = (roomCode: string) => {
  if (typeof window === 'undefined') return
  const raw = localStorage.getItem(savedRoomsKey)
  const parsed = raw ? JSON.parse(raw) : []
  const rooms = Array.isArray(parsed) ? parsed : []
  const normalizedTarget = normalizeRoomCode(roomCode)
  const filtered = rooms.filter((entry: { code: string }) => normalizeRoomCode(entry.code) !== normalizedTarget)
  localStorage.setItem(savedRoomsKey, JSON.stringify(filtered))
}

const clearParticipantStorage = (roomCode: string) => {
  if (typeof window === 'undefined') return
  localStorage.removeItem(`participant_${roomCode}`)
  localStorage.removeItem(`room_master_${roomCode}`)
  sessionStorage.removeItem(`participant_session_${roomCode}`)
}

const handleRefresh = () => {
  executeQuery({ requestPolicy: 'network-only' })
}

const deleteRoomMutation = useMutation(DeleteRoomDocument)
const removeParticipantMutation = useMutation(
  parse(`
    mutation RemoveParticipant($roomId: ID!, $participantId: ID!, $targetParticipantId: ID!) {
      removeParticipant(
        roomId: $roomId,
        participantId: $participantId,
        targetParticipantId: $targetParticipantId
      ) {
        success
        errors
      }
    }
  `)
)

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
    const normalizedCode = normalizeRoomCode(room.value.code)
    removeSavedRoom(normalizedCode)
    clearParticipantStorage(normalizedCode)
    await navigateTo('/')
  } else {
    deleteError.value = result.data?.deleteRoom?.errors?.[0] || 'ルームの削除に失敗しました'
  }

  deletingRoom.value = false
}

const removeParticipantError = ref('')

const handleRemoveParticipant = async (targetParticipantId: string) => {
  if (!room.value || !currentParticipantId.value || !isRoomMaster.value) return
  if (targetParticipantId === roomMasterId.value) return
  if (!confirm('この参加者を削除しますか？')) return

  removeParticipantError.value = ''

  const result = await removeParticipantMutation.executeMutation({
    roomId: room.value.id,
    participantId: currentParticipantId.value,
    targetParticipantId,
  })

  if (result.data?.removeParticipant?.success) {
    handleRefresh()
  } else {
    removeParticipantError.value =
      result.data?.removeParticipant?.errors?.[0] || '参加者の削除に失敗しました'
  }
}

let pollTimer: ReturnType<typeof setInterval> | null = null

const hasNoTopics = computed(() => {
  return !room.value?.topics || room.value.topics.length === 0
})

const hasDraftTopics = computed(() => {
  return room.value?.topics.some((t: { status: string }) => t.status === 'DRAFT' || t.status === 'draft') || false
})

const hasOrganizingTopics = computed(() => {
  return room.value?.topics.some((t: { status: string }) => t.status === 'ORGANIZING' || t.status === 'organizing') || false
})

const votingTopics = computed(() => {
  if (!room.value) return []
  return room.value.topics.filter((t: { status: string }) => {
    const status = t.status.toUpperCase()
    return ['CURRENT_VOTING', 'CURRENT_REVEALED', 'DESIRED_VOTING', 'DESIRED_REVEALED', 'COMPLETED'].includes(status) ||
           ['current_voting', 'current_revealed', 'desired_voting', 'desired_revealed', 'completed'].includes(t.status)
  })
})

const currentPhase = computed(() => {
  if (hasNoTopics.value || hasDraftTopics.value) return 'draft'
  if (hasOrganizingTopics.value) return 'organizing'
  return 'voting'
})

const currentPhaseLabel = computed(() => {
  if (currentPhase.value === 'draft') return '話し合いたい対象出し'
  if (currentPhase.value === 'organizing') return '整理フェーズ'
  return '投票フェーズ'
})

const currentPhaseBadgeClass = computed(() => {
  if (currentPhase.value === 'draft') return 'badge-neutral'
  if (currentPhase.value === 'organizing') return 'badge-warning'
  return 'badge-info'
})

const phaseStepClass = (phase: 'draft' | 'organizing' | 'voting') => {
  if (currentPhase.value === phase) {
    if (phase === 'draft') return 'phase-draft border-gray-400'
    if (phase === 'organizing') return 'phase-organizing border-yellow-400'
    return 'phase-current-voting border-blue-400'
  }

  if (currentPhase.value === 'organizing' && phase === 'draft') {
    return 'bg-gray-100 border-gray-200'
  }

  if (currentPhase.value === 'voting' && (phase === 'draft' || phase === 'organizing')) {
    return 'bg-gray-100 border-gray-200'
  }

  return 'bg-white border-gray-200'
}

const phaseStepIcon = (phase: 'draft' | 'organizing' | 'voting') => {
  if (currentPhase.value === phase) return '▶️'
  if (currentPhase.value === 'organizing' && phase === 'draft') return '✅'
  if (currentPhase.value === 'voting' && (phase === 'draft' || phase === 'organizing')) return '✅'
  return '⬜️'
}

// ローカルストレージから参加者IDを取得（簡易実装）
const currentParticipantId = ref<string | null>(null)
const roomMasterId = ref<string | null>(null)

if (typeof window !== 'undefined') {
  const upperCode = code.toUpperCase()
  currentParticipantId.value =
    sessionStorage.getItem(`participant_session_${upperCode}`) ||
    localStorage.getItem(`participant_${upperCode}`)
  roomMasterId.value = localStorage.getItem(`room_master_${upperCode}`)
}

const isCurrentParticipantInRoom = (roomValue: typeof room.value, participantId: string | null) => {
  if (!roomValue || !participantId) return false
  return roomValue.participants.some((participant: { id: string }) => participant.id === participantId)
}

watch(
  [() => room.value, () => currentParticipantId.value],
  ([value, participantId]) => {
    if (!value) return
    hasLoaded.value = true
    if (!isCurrentParticipantInRoom(value, participantId)) {
      roomAccessError.value = 'ルームは解散しました'
      const normalizedCode = normalizeRoomCode(value.code)
      removeSavedRoom(normalizedCode)
      clearParticipantStorage(normalizedCode)
      return
    }

    if (typeof window !== 'undefined') {
      if (value.roomMasterId) {
        roomMasterId.value = value.roomMasterId
        localStorage.setItem(`room_master_${normalizeRoomCode(value.code)}`, value.roomMasterId)
      }
      const raw = localStorage.getItem(savedRoomsKey)
      const parsed = raw ? JSON.parse(raw) : []
      const rooms = Array.isArray(parsed) ? parsed : []
      const now = new Date().toISOString()
      const normalizedCode = normalizeRoomCode(value.code)
      const existingIndex = rooms.findIndex(
        (entry: { code: string }) => normalizeRoomCode(entry.code) === normalizedCode
      )
      const updatedEntry = { code: normalizedCode, name: value.name, updatedAt: now }

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
