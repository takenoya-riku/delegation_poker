<template>
  <div class="card-modern border-2 border-blue-200 bg-gradient-to-r from-white to-blue-50 shadow-lg">
    <div class="card-body p-6">
      <div class="flex items-center gap-2 mb-4">
        <div class="w-10 h-10 rounded-full bg-gradient-success flex items-center justify-center text-white font-bold shadow-md">
          👥
        </div>
        <h2 class="card-title text-xl text-gray-800">参加者</h2>
        <span class="badge badge-primary badge-lg px-3 py-1">{{ participants.length }}人</span>
      </div>
      <div class="flex flex-wrap gap-3">
        <div
          v-for="participant in participants"
          :key="participant.id"
          class="badge badge-lg px-4 py-2 bg-gradient-to-r from-blue-500 to-purple-500 text-white border-0 shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-105"
        >
          <span class="mr-1">👤</span>
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
