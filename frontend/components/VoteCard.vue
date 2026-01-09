<template>
  <div class="space-y-4">
    <div>
      <p class="text-sm font-semibold mb-2">権限レベルを選択してください</p>
      <div class="grid grid-cols-7 gap-2">
        <button
          v-for="level in [1, 2, 3, 4, 5, 6, 7]"
          :key="level"
          class="btn"
          :class="{
            'btn-primary': currentVote === level,
            'btn-outline': currentVote !== level
          }"
          @click="handleVote(level)"
          :disabled="voting"
        >
          {{ level }}
        </button>
      </div>
    </div>
    <div v-if="voting" class="text-sm text-gray-500">投票中...</div>
    <div v-if="voteError" class="alert alert-error">
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
  votes: Array<{
    id: string
    level: number
    participant: {
      id: string
    }
  }>
}>()

const emit = defineEmits<{
  voted: []
}>()

const currentVote = computed(() => {
  const vote = props.votes.find(v => v.participant.id === props.participantId)
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
    level
  })

  if (result.data?.vote?.vote) {
    emit('voted')
  } else {
    voteError.value = result.data?.vote?.errors?.[0] || '投票に失敗しました'
  }

  voting.value = false
}
</script>
