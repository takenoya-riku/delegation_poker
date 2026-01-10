<template>
  <div class="space-y-4">
    <div>
      <p class="text-base font-semibold mb-4 text-gray-700">{{ voteTypeLabel }}の権限レベルを選択してください</p>
      <div class="grid grid-cols-7 gap-3">
        <button
          v-for="level in [1, 2, 3, 4, 5, 6, 7]"
          :key="level"
          class="btn h-16 text-lg font-bold rounded-xl transition-all duration-300 transform hover:scale-110 shadow-md hover:shadow-lg"
          :class="{
            'bg-gradient-to-br from-purple-500 to-pink-500 text-white border-0 animate-pulse-glow': currentVote === level,
            'bg-white border-2 border-gray-300 text-gray-700 hover:border-purple-400 hover:bg-purple-50': currentVote !== level
          }"
          @click="handleVote(level)"
          :disabled="voting"
        >
          {{ level }}
        </button>
      </div>
    </div>
    <div v-if="voting" class="flex items-center gap-2 text-sm text-gray-600 animate-fade-in">
      <span class="loading loading-spinner loading-sm"></span>
      投票中...
    </div>
    <div v-if="voteError" class="alert alert-error shadow-md animate-fade-in">
      <span>{{ voteError }}</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { VoteDocument } from '~/graphql/generated/types'

const props = defineProps<{
  topicId: string
  participantId: string
  voteType: 'current_state' | 'desired_state'
  votes: Array<{
    id: string
    level: number
    voteType: string
    participant: {
      id: string
    }
  }>
}>()

const emit = defineEmits<{
  voted: []
}>()

const voteTypeLabel = computed(() => {
  return props.voteType === 'current_state' ? '現状確認' : 'ありたい姿'
})

const currentVote = computed(() => {
  const vote = props.votes.find(
    v => v.participant.id === props.participantId && v.voteType === props.voteType
  )
  return vote?.level || null
})

const voting = ref(false)
const voteError = ref('')

const voteMutation = useMutation(VoteDocument)

const handleVote = async (level: number) => {
  voting.value = true
  voteError.value = ''

  const result = await voteMutation.executeMutation({
    topicId: props.topicId,
    participantId: props.participantId,
    level,
    voteType: props.voteType.toUpperCase()
  })

  if (result.data?.vote?.vote) {
    emit('voted')
  } else {
    voteError.value = result.data?.vote?.errors?.[0] || '投票に失敗しました'
  }

  voting.value = false
}
</script>

