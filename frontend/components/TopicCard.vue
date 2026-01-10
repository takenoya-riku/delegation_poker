<template>
  <div :class="cardClass" class="card-modern shadow-xl transition-all duration-300 hover:shadow-2xl">
    <div class="card-body p-6">
      <div class="flex items-start justify-between mb-4">
        <div class="flex-1">
          <h3 class="card-title text-2xl font-bold text-gray-800 mb-2">{{ topic.title }}</h3>
          <p v-if="topic.description" class="text-sm text-gray-600 mb-3">{{ topic.description }}</p>
        </div>
        <div :class="badgeClass" class="badge badge-lg px-4 py-2 font-semibold shadow-md">
          {{ statusLabel }}
        </div>
      </div>

      <!-- 現状確認投票中 -->
      <div v-if="topic.status === 'CURRENT_VOTING' || topic.status === 'current_voting'" class="mt-6">
        <div class="mb-4">
          <h4 class="text-lg font-semibold text-gray-700 mb-2 flex items-center gap-2">
            <span class="text-2xl">📊</span>
            現状確認（投票）
          </h4>
        </div>
        <VoteCard
          v-if="participantId"
          :topic-id="topic.id"
          :participant-id="participantId"
          :vote-type="'current_state'"
          :votes="topic.votes"
          @voted="$emit('refresh')"
        />
        <div v-else class="alert alert-info shadow-md">
          <span>投票するにはルームに参加してください</span>
        </div>
        <div v-if="canRevealCurrent" class="mt-6">
          <button @click="handleRevealCurrent" class="btn-gradient-secondary w-full py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300" :disabled="revealing">
            <span v-if="revealing" class="loading loading-spinner loading-sm mr-2"></span>
            {{ revealing ? '公開中...' : '✨ 現状確認結果を公開' }}
          </button>
        </div>
      </div>

      <!-- 現状確認結果公開済み -->
      <div v-else-if="topic.status === 'CURRENT_REVEALED' || topic.status === 'current_revealed'" class="mt-6">
        <div class="mb-4">
          <h4 class="text-lg font-semibold text-gray-700 mb-2 flex items-center gap-2">
            <span class="text-2xl">✅</span>
            現状確認（結果）
          </h4>
        </div>
        <VoteResults :votes="topic.votes" vote-type="current_state" />
        <div v-if="canStartDesired" class="mt-6">
          <button @click="handleStartDesired" class="btn-gradient w-full py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300" :disabled="starting">
            <span v-if="starting" class="loading loading-spinner loading-sm mr-2"></span>
            {{ starting ? '開始中...' : '🎯 ありたい姿投票を開始' }}
          </button>
        </div>
      </div>

      <!-- ありたい姿投票中 -->
      <div v-else-if="topic.status === 'DESIRED_VOTING' || topic.status === 'desired_voting'" class="mt-6">
        <div class="mb-4">
          <h4 class="text-lg font-semibold text-gray-700 mb-2 flex items-center gap-2">
            <span class="text-2xl">🎯</span>
            ありたい姿（投票）
          </h4>
        </div>
        <VoteCard
          v-if="participantId"
          :topic-id="topic.id"
          :participant-id="participantId"
          :vote-type="'desired_state'"
          :votes="topic.votes"
          @voted="$emit('refresh')"
        />
        <div v-else class="alert alert-info shadow-md">
          <span>投票するにはルームに参加してください</span>
        </div>
        <div v-if="canRevealDesired" class="mt-6">
          <button @click="handleRevealDesired" class="btn-gradient-secondary w-full py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300" :disabled="revealing">
            <span v-if="revealing" class="loading loading-spinner loading-sm mr-2"></span>
            {{ revealing ? '公開中...' : '✨ ありたい姿結果を公開' }}
          </button>
        </div>
      </div>

      <!-- ありたい姿結果公開済みまたは完了 -->
      <div v-else-if="topic.status === 'DESIRED_REVEALED' || topic.status === 'desired_revealed' || topic.status === 'COMPLETED' || topic.status === 'completed'" class="mt-6 space-y-6">
        <div>
          <h4 class="text-lg font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <span class="text-2xl">📊</span>
            現状確認の投票結果
          </h4>
          <VoteResults :votes="topic.votes" vote-type="current_state" />
        </div>
        <div>
          <h4 class="text-lg font-semibold text-gray-700 mb-3 flex items-center gap-2">
            <span class="text-2xl">🎯</span>
            ありたい姿の投票結果
          </h4>
          <VoteResults :votes="topic.votes" vote-type="desired_state" />
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { RevealCurrentStateDocument, StartDesiredStateVotingDocument, RevealDesiredStateDocument } from '~/graphql/generated/types'

const props = defineProps<{
  topic: {
    id: string
    title: string
    description: string | null
    status: string
    votes: Array<{
      id: string
      level: number
      voteType: string
      participant: {
        id: string
        name: string
      }
    }>
    allParticipantsVoted?: boolean
  }
  participantId: string | null
  totalParticipants?: number
}>()

const emit = defineEmits<{
  refresh: []
}>()

const statusLabel = computed(() => {
  const status = props.topic.status.toLowerCase()
  const labels: Record<string, string> = {
    draft: '対象出し',
    organizing: '整理中',
    current_voting: '現状確認投票中',
    current_revealed: '現状確認結果公開済み',
    desired_voting: 'ありたい姿投票中',
    desired_revealed: 'ありたい姿結果公開済み',
    completed: '完了'
  }
  return labels[status] || props.topic.status
})

const cardClass = computed(() => {
  const status = props.topic.status.toLowerCase()
  const classes: Record<string, string> = {
    draft: 'border-2 border-gray-300 bg-gradient-to-br from-white to-gray-50',
    organizing: 'border-2 border-yellow-300 bg-gradient-to-br from-white to-yellow-50',
    current_voting: 'border-2 border-blue-300 bg-gradient-to-br from-white to-blue-50',
    current_revealed: 'border-2 border-green-300 bg-gradient-to-br from-white to-green-50',
    desired_voting: 'border-2 border-purple-300 bg-gradient-to-br from-white to-purple-50',
    desired_revealed: 'border-2 border-indigo-300 bg-gradient-to-br from-white to-indigo-50',
    completed: 'border-2 border-gray-200 bg-gradient-to-br from-gray-50 to-white'
  }
  return classes[status] || 'border-2 border-gray-200'
})

const badgeClass = computed(() => {
  const status = props.topic.status.toLowerCase()
  const classes: Record<string, string> = {
    draft: 'badge-neutral',
    organizing: 'badge-warning',
    current_voting: 'badge-info',
    current_revealed: 'badge-success',
    desired_voting: 'badge-primary',
    desired_revealed: 'badge-secondary',
    completed: 'badge-ghost'
  }
  return classes[status] || 'badge-outline'
})

const canRevealCurrent = computed(() => {
  return (props.topic.status === 'CURRENT_VOTING' || props.topic.status === 'current_voting') && props.topic.allParticipantsVoted
})

const canStartDesired = computed(() => {
  return props.topic.status === 'CURRENT_REVEALED' || props.topic.status === 'current_revealed'
})

const canRevealDesired = computed(() => {
  return (props.topic.status === 'DESIRED_VOTING' || props.topic.status === 'desired_voting') && props.topic.allParticipantsVoted
})

const revealing = ref(false)
const starting = ref(false)

const revealCurrentMutation = useMutation(RevealCurrentStateDocument)
const startDesiredMutation = useMutation(StartDesiredStateVotingDocument)
const revealDesiredMutation = useMutation(RevealDesiredStateDocument)

const handleRevealCurrent = async () => {
  revealing.value = true
  const result = await revealCurrentMutation.executeMutation({ topicId: props.topic.id })
  if (result.data?.revealCurrentState?.topic) {
    emit('refresh')
  }
  revealing.value = false
}

const handleStartDesired = async () => {
  starting.value = true
  const result = await startDesiredMutation.executeMutation({ topicId: props.topic.id })
  if (result.data?.startDesiredStateVoting?.topic) {
    emit('refresh')
  }
  starting.value = false
}

const handleRevealDesired = async () => {
  revealing.value = true
  const result = await revealDesiredMutation.executeMutation({ topicId: props.topic.id })
  if (result.data?.revealDesiredState?.topic) {
    emit('refresh')
  }
  revealing.value = false
}
</script>

