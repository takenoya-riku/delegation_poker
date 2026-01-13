<template>
  <div class="space-y-4">
    <h4
      v-if="title"
      class="font-semibold text-lg text-gray-700 mb-4"
    >
      {{ title }}
    </h4>
    <div
      v-if="filteredVotes.length === 0"
      class="text-center py-8 text-gray-500 bg-gray-50 rounded-xl border-2 border-dashed border-gray-300"
    >
      <span class="text-4xl mb-2 block">📭</span>
      まだ投票がありません
    </div>
    <div
      v-else
      class="space-y-3"
    >
      <div
        v-for="vote in filteredVotes"
        :key="vote.id"
        class="flex items-center justify-between p-4 bg-gradient-to-r from-white to-purple-50 rounded-xl border-2 border-purple-200 shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-[1.02]"
      >
        <div class="flex items-center gap-3">
          <div class="w-10 h-10 rounded-full bg-gradient-to-br from-purple-400 to-pink-400 flex items-center justify-center text-white font-bold shadow-md">
            👤
          </div>
          <span class="font-semibold text-gray-700">{{ vote.participant.name }}</span>
        </div>
        <span class="badge badge-lg px-4 py-2 bg-gradient-to-r from-purple-500 to-pink-500 text-white border-0 shadow-md font-bold">
          レベル {{ vote.level }}
        </span>
      </div>
    </div>
    <div
      v-if="filteredVotes.length > 0"
      class="stats shadow-lg bg-gradient-to-r from-purple-50 to-pink-50 border-2 border-purple-200 rounded-xl mt-6"
    >
      <div class="stat">
        <div class="stat-title text-gray-600 font-semibold">
          平均
        </div>
        <div class="stat-value text-purple-600">
          {{ averageLevel.toFixed(1) }}
        </div>
      </div>
      <div class="stat">
        <div class="stat-title text-gray-600 font-semibold">
          最大
        </div>
        <div class="stat-value text-pink-600">
          {{ maxLevel }}
        </div>
      </div>
      <div class="stat">
        <div class="stat-title text-gray-600 font-semibold">
          最小
        </div>
        <div class="stat-value text-blue-600">
          {{ minLevel }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  votes: Array<{
    id: string
    level: number
    voteType: string
    participant: {
      id: string
      name: string
    }
  }>
  voteType?: 'current_state' | 'desired_state'
  title?: string
}>()

const filteredVotes = computed(() => {
  if (props.voteType) {
    return props.votes.filter(v => v.voteType === props.voteType)
  }
  return props.votes
})

const defaultTitle = computed(() => {
  if (props.voteType === 'current_state') return '現状確認の投票結果'
  if (props.voteType === 'desired_state') return 'ありたい姿の投票結果'
  return '投票結果'
})

const title = computed(() => props.title || defaultTitle.value)

const averageLevel = computed(() => {
  if (filteredVotes.value.length === 0) return 0
  const sum = filteredVotes.value.reduce((acc, vote) => acc + vote.level, 0)
  return sum / filteredVotes.value.length
})

const maxLevel = computed(() => {
  if (filteredVotes.value.length === 0) return 0
  return Math.max(...filteredVotes.value.map(v => v.level))
})

const minLevel = computed(() => {
  if (filteredVotes.value.length === 0) return 0
  return Math.min(...filteredVotes.value.map(v => v.level))
})
</script>

