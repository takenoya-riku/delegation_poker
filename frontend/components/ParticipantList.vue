<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">参加者 ({{ participants.length }})</h2>
      <div class="flex flex-wrap gap-2">
        <div
          v-for="participant in participants"
          :key="participant.id"
          class="badge badge-primary badge-lg"
        >
          {{ participant.name }}
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
defineProps<{
  participants: Array<{
    id: string
    name: string
  }>
}>()
</script>
