<template>
  <div class="space-y-4">
    <h4 class="font-semibold">投票結果</h4>
    <div class="space-y-2">
      <div
        v-for="vote in votes"
        :key="vote.id"
        class="flex items-center justify-between p-2 bg-base-200 rounded"
      >
        <span>{{ vote.participant.name }}</span>
        <span class="badge badge-primary badge-lg">レベル {{ vote.level }}</span>
      </div>
    </div>
    <div v-if="votes.length === 0" class="text-sm text-gray-500">
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
    participant: {
      id: string
      name: string
    }
  }>
}>()

const averageLevel = computed(() => {
  if (props.votes.length === 0) return 0
  const sum = props.votes.reduce((acc, vote) => acc + vote.level, 0)
  return sum / props.votes.length
})

const maxLevel = computed(() => {
  if (props.votes.length === 0) return 0
  return Math.max(...props.votes.map(v => v.level))
})

const minLevel = computed(() => {
  if (props.votes.length === 0) return 0
  return Math.min(...props.votes.map(v => v.level))
})
</script>
