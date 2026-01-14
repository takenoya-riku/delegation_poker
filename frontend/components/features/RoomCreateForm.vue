<template>
  <FormCard
    title="ルームを作成"
    card-class="border-purple-200 hover:border-purple-300"
    icon-class="bg-gradient-primary"
  >
    <template #icon>
      ➕
    </template>
    <form
      class="space-y-6"
      @submit.prevent="handleCreate"
    >
      <FormField
        v-model="roomName"
        label="ルーム名"
        placeholder="例: プロジェクトAの意思決定"
        input-class="focus:input-primary focus:ring-2 focus:ring-purple-500 transition-all duration-300"
        required
      />
      <FormField
        v-model="participantName"
        label="あなたの名前"
        placeholder="例: 山田太郎"
        input-class="focus:input-primary focus:ring-2 focus:ring-purple-500 transition-all duration-300"
        required
      />
      <div class="form-control">
        <button
          type="submit"
          class="btn-gradient w-full text-lg py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300"
          :disabled="creating"
        >
          <span
            v-if="creating"
            class="loading loading-spinner loading-sm mr-2"
          />
          {{ creating ? '作成中...' : '✨ ルームを作成' }}
        </button>
      </div>
      <div
        v-if="error"
        class="alert alert-error mt-4 shadow-md animate-fade-in"
      >
        <span>{{ error }}</span>
      </div>
    </form>
  </FormCard>
</template>

<script setup lang="ts">
import { useRoomActions } from '~/composables/useRoomActions'
import FormCard from '~/components/ui/FormCard.vue'
import FormField from '~/components/ui/FormField.vue'

const roomName = ref('')
const participantName = ref('')
const creating = ref(false)
const error = ref('')

const { createRoom, joinRoom } = useRoomActions()

const handleCreate = async () => {
  if (!roomName.value.trim() || !participantName.value.trim()) return

  creating.value = true
  error.value = ''

  const result = await createRoom({
    name: roomName.value.trim()
  })

  if (result.data?.createRoom?.room) {
    const code = result.data.createRoom.room.code
    const joinResult = await joinRoom({
      code,
      name: participantName.value.trim()
    })

    if (joinResult.data?.joinRoom?.participant) {
      const participantId = joinResult.data.joinRoom.participant.id
      if (typeof window !== 'undefined') {
        const upperCode = code.toUpperCase()
        localStorage.setItem(`participant_${upperCode}`, participantId)
        sessionStorage.setItem(`participant_session_${upperCode}`, participantId)
        localStorage.setItem(`room_master_${upperCode}`, participantId)
      }
      await navigateTo(`/room/${code}`)
    } else {
      error.value = joinResult.data?.joinRoom?.errors?.[0] || 'ルーム作成後の参加に失敗しました'
    }
  } else {
    error.value = result.data?.createRoom?.errors?.[0] || 'ルームの作成に失敗しました'
  }

  creating.value = false
}
</script>
