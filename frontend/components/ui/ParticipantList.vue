<template>
  <div class="card-modern border-2 border-blue-200 bg-gradient-to-r from-white to-blue-50 shadow-lg">
    <div class="card-body p-6">
      <div class="flex items-center gap-2 mb-4">
        <div class="w-10 h-10 rounded-full bg-gradient-success flex items-center justify-center text-white font-bold shadow-md">
          👥
        </div>
        <h2 class="card-title text-xl text-gray-800">
          参加者
        </h2>
        <span class="badge badge-primary badge-lg px-3 py-1">{{ participants.length }}人</span>
      </div>
      <div class="flex flex-wrap gap-3">
        <div
          v-for="participant in participants"
          :key="participant.id"
          class="badge badge-lg px-4 py-2 text-white border-0 shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-105"
          :class="participantBadgeClass(participant.id)"
        >
          <span class="mr-1">{{ participantIcon(participant.id) }}</span>
          {{ participant.name }}
          <button
            v-if="canRemoveParticipant(participant.id)"
            type="button"
            class="ml-2 inline-flex items-center justify-center rounded-full bg-white/20 px-2 py-0.5 text-xs text-white hover:bg-white/30"
            aria-label="参加者を削除"
            @click.stop="emit('remove', participant.id)"
          >
            ✕
          </button>
          <span
            v-if="participant.id === currentParticipantId"
            class="ml-2 text-xs bg-white/20 px-2 py-0.5 rounded-full"
          >
            あなた
          </span>
          <span
            v-if="participant.id === roomMasterId"
            class="ml-2 text-xs bg-white/20 px-2 py-0.5 rounded-full"
          >
            ルームマスター
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{
  participants: Array<{
    id: string
    name: string
  }>
  currentParticipantId: string | null
  isRoomMaster?: boolean
  roomMasterId?: string | null
}>()

const emit = defineEmits<{
  remove: [participantId: string]
}>()

const participantBadgeClass = (participantId: string) => {
  if (participantId === props.currentParticipantId) {
    return 'bg-gradient-to-r from-emerald-500 to-teal-500 ring-2 ring-emerald-300 ring-offset-2 ring-offset-white'
  }
  if (participantId === props.roomMasterId) {
    return 'bg-gradient-to-r from-amber-500 to-orange-500 ring-2 ring-amber-300 ring-offset-2 ring-offset-white'
  }
  return 'bg-gradient-to-r from-blue-500 to-purple-500'
}

const participantIcon = (participantId: string) => {
  if (participantId === props.currentParticipantId) return '⭐'
  if (participantId === props.roomMasterId) return '👑'
  return '👤'
}

const canRemoveParticipant = (participantId: string) => {
  if (!props.isRoomMaster) return false
  if (!props.roomMasterId) return false
  return participantId !== props.roomMasterId
}
</script>
