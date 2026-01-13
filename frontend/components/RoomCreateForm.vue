<template>
  <div class="card-modern card-gradient border-2 border-purple-200 hover:border-purple-300 transition-all duration-300">
    <div class="card-body p-8">
      <div class="flex items-center gap-3 mb-6">
        <div class="w-12 h-12 rounded-full bg-gradient-primary flex items-center justify-center text-white text-xl font-bold shadow-lg">
          ➕
        </div>
        <h2 class="card-title text-2xl text-gray-800">
          ルームを作成
        </h2>
      </div>
      <form
        class="space-y-6"
        @submit.prevent="handleCreate"
      >
        <div class="form-control">
          <label class="label">
            <span class="label-text font-semibold text-gray-700">ルーム名</span>
          </label>
          <input
            v-model="roomName"
            type="text"
            placeholder="例: プロジェクトAの意思決定"
            class="input input-bordered w-full px-[5px] focus:input-primary focus:ring-2 focus:ring-purple-500 transition-all duration-300"
            required
          >
        </div>
        <div class="form-control">
          <label class="label">
            <span class="label-text font-semibold text-gray-700">あなたの名前</span>
          </label>
          <input
            v-model="participantName"
            type="text"
            placeholder="例: 山田太郎"
            class="input input-bordered w-full px-[5px] focus:input-primary focus:ring-2 focus:ring-purple-500 transition-all duration-300"
            required
          >
        </div>
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
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { CreateRoomDocument, JoinRoomDocument } from '~/graphql/generated/types'

const roomName = ref('')
const participantName = ref('')
const creating = ref(false)
const error = ref('')

const createRoomMutation = useMutation(CreateRoomDocument)
const joinRoomMutation = useMutation(JoinRoomDocument)

const handleCreate = async () => {
  if (!roomName.value.trim() || !participantName.value.trim()) return

  creating.value = true
  error.value = ''

  const result = await createRoomMutation.executeMutation({
    name: roomName.value.trim()
  })

  if (result.data?.createRoom?.room) {
    const code = result.data.createRoom.room.code
    const joinResult = await joinRoomMutation.executeMutation({
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
