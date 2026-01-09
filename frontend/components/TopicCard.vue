<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h3 class="card-title">{{ topic.title }}</h3>
      <p v-if="topic.description" class="text-sm text-gray-600">{{ topic.description }}</p>

      <div v-if="topic.status === 'voting'">
        <VoteCard
          v-if="participantId"
          :topic-id="topic.id"
          :participant-id="participantId"
          :votes="topic.votes"
          @voted="$emit('refresh')"
        />
        <div v-else class="alert alert-info">
          <span>投票するにはルームに参加してください</span>
        </div>
      </div>

      <div v-else>
        <VoteResults :votes="topic.votes" />
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  topic: {
    id: string
    title: string
    description: string | null
    status: string
    votes: Array<{
      id: string
      level: number
      participant: {
        id: string
        name: string
      }
    }>
  }
  participantId: string | null
}>()

const emit = defineEmits<{
  refresh: []
}>()
</script>
