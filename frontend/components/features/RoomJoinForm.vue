<template>
  <FormCard
    title="ルームに参加"
    card-class="border-blue-200 hover:border-blue-300"
    icon-class="bg-gradient-success"
  >
    <template #icon>
      🚪
    </template>
    <form
      class="space-y-6"
      @submit.prevent="handleJoin"
    >
      <FormField
        v-model="roomCode"
        label="ルームコード"
        placeholder="6桁のコード"
        input-class="focus:input-primary focus:ring-2 focus:ring-blue-500 transition-all duration-300 text-center text-2xl font-bold tracking-widest uppercase"
        maxlength="6"
        required
      />
      <FormField
        v-model="participantName"
        label="あなたの名前"
        placeholder="例: 山田太郎"
        input-class="focus:input-primary focus:ring-2 focus:ring-blue-500 transition-all duration-300"
        required
      />
      <div class="form-control">
        <button
          type="submit"
          class="btn-gradient-secondary w-full text-lg py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300"
          :disabled="joining"
        >
          <span
            v-if="joining"
            class="loading loading-spinner loading-sm mr-2"
          />
          {{ joining ? '参加中...' : '🎯 ルームに参加' }}
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

const roomCode = ref('')
const participantName = ref('')
const joining = ref(false)
const error = ref('')

const { joinRoom } = useRoomActions()

const handleJoin = async () => {
  if (!roomCode.value.trim() || !participantName.value.trim()) return

  joining.value = true
  error.value = ''

  const result = await joinRoom({
    code: roomCode.value.trim().toUpperCase(),
    name: participantName.value.trim()
  })

    if (result.data?.joinRoom?.participant) {
      const code = result.data.joinRoom.room.code
      const participantId = result.data.joinRoom.participant.id
      // 参加者IDをローカルストレージに保存
      if (typeof window !== 'undefined') {
        const upperCode = code.toUpperCase()
        localStorage.setItem(`participant_${upperCode}`, participantId)
        sessionStorage.setItem(`participant_session_${upperCode}`, participantId)
      }
      await navigateTo(`/room/${code}`)
  } else {
    error.value = result.data?.joinRoom?.errors?.[0] || 'ルームへの参加に失敗しました'
  }

  joining.value = false
}
</script>
