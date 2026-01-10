<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h3 class="card-title">{{ topic.title }}</h3>
      <p v-if="topic.description" class="text-sm text-gray-600">{{ topic.description }}</p>
      <div class="badge badge-outline">{{ statusLabel }}</div>

      <!-- 現状確認投票中 -->
      <div v-if="topic.status === 'current_voting'" class="mt-4">
        <VoteCard
          v-if="participantId"
          :topic-id="topic.id"
          :participant-id="participantId"
          :vote-type="'current_state'"
          :votes="topic.votes"
          @voted="$emit('refresh')"
        />
        <div v-else class="alert alert-info">
          <span>投票するにはルームに参加してください</span>
        </div>
        <div v-if="canRevealCurrent" class="mt-4">
          <button @click="handleRevealCurrent" class="btn btn-primary" :disabled="revealing">
            {{ revealing ? '公開中...' : '現状確認結果を公開' }}
          </button>
        </div>
      </div>

      <!-- 現状確認結果公開済み -->
      <div v-else-if="topic.status === 'current_revealed'" class="mt-4">
        <VoteResults :votes="topic.votes" vote-type="current_state" />
        <div v-if="canStartDesired" class="mt-4">
          <button @click="handleStartDesired" class="btn btn-primary" :disabled="starting">
            {{ starting ? '開始中...' : 'ありたい姿投票を開始' }}
          </button>
        </div>
      </div>

      <!-- ありたい姿投票中 -->
      <div v-else-if="topic.status === 'desired_voting'" class="mt-4">
        <VoteCard
          v-if="participantId"
          :topic-id="topic.id"
          :participant-id="participantId"
          :vote-type="'desired_state'"
          :votes="topic.votes"
          @voted="$emit('refresh')"
        />
        <div v-else class="alert alert-info">
          <span>投票するにはルームに参加してください</span>
        </div>
        <div v-if="canRevealDesired" class="mt-4">
          <button @click="handleRevealDesired" class="btn btn-primary" :disabled="revealing">
            {{ revealing ? '公開中...' : 'ありたい姿結果を公開' }}
          </button>
        </div>
      </div>

      <!-- ありたい姿結果公開済みまたは完了 -->
      <div v-else-if="topic.status === 'desired_revealed' || topic.status === 'completed'" class="mt-4">
        <VoteResults :votes="topic.votes" vote-type="current_state" title="現状確認の投票結果" />
        <VoteResults :votes="topic.votes" vote-type="desired_state" title="ありたい姿の投票結果" class="mt-4" />
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
  const labels: Record<string, string> = {
    draft: '対象出し',
    organizing: '整理中',
    current_voting: '現状確認投票中',
    current_revealed: '現状確認結果公開済み',
    desired_voting: 'ありたい姿投票中',
    desired_revealed: 'ありたい姿結果公開済み',
    completed: '完了'
  }
  return labels[props.topic.status] || props.topic.status
})

const canRevealCurrent = computed(() => {
  return props.topic.status === 'current_voting' && props.topic.allParticipantsVoted
})

const canStartDesired = computed(() => {
  return props.topic.status === 'current_revealed'
})

const canRevealDesired = computed(() => {
  return props.topic.status === 'desired_voting' && props.topic.allParticipantsVoted
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

