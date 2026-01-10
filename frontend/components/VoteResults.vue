<template>
  <div class="space-y-4">
    <h4 class="font-semibold">{{ title }}</h4>
    <div class="space-y-2">
      <div
        v-for="vote in filteredVotes"
        :key="vote.id"
        class="flex items-center justify-between p-2 bg-base-200 rounded"
      >
        <span>{{ vote.participant.name }}</span>
        <span class="badge badge-primary badge-lg">レベル {{ vote.level }}</span>
      </div>
    </div>
    <div v-if="filteredVotes.length === 0" class="text-sm text-gray-500">
      まだ投票がありません
    </div>
    <div v-else class="stats shadow">
      <div class="stat">
        <div class="stat-title">平均</div>
        <div class="stat-value">{{ averageLevel.toFixed(1) }}</div>
      </div>
      <div class="stat">
        <div class="stat-title">最大</div>
        <div class="stat-value">{{ maxLevel }}</div>
      </div>
      <div class="stat">
        <div class="stat-title">最小</div>
        <div class="stat-value">{{ minLevel }}</div>
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

