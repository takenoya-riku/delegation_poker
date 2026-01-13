<template>
  <div class="card-modern card-gradient border-2 border-blue-200 hover:border-blue-300 transition-all duration-300">
    <div class="card-body p-8">
      <div class="flex items-center gap-3 mb-6">
        <div class="w-12 h-12 rounded-full bg-gradient-success flex items-center justify-center text-white text-xl font-bold shadow-lg">
          🚪
        </div>
        <h2 class="card-title text-2xl text-gray-800">
          ルームに参加
        </h2>
      </div>
      <form
        class="space-y-6"
        @submit.prevent="handleJoin"
      >
        <div class="form-control">
          <label class="label">
            <span class="label-text font-semibold text-gray-700">ルームコード</span>
          </label>
          <input
            v-model="roomCode"
            type="text"
            placeholder="6桁のコード"
            class="input input-bordered w-full px-[5px] focus:input-primary focus:ring-2 focus:ring-blue-500 transition-all duration-300 text-center text-2xl font-bold tracking-widest uppercase"
            maxlength="6"
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
            class="input input-bordered w-full px-[5px] focus:input-primary focus:ring-2 focus:ring-blue-500 transition-all duration-300"
            required
          >
        </div>
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
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { JoinRoomDocument } from '~/graphql/generated/types'

const roomCode = ref('')
const participantName = ref('')
const joining = ref(false)
const error = ref('')

const joinRoomMutation = useMutation(JoinRoomDocument)

const handleJoin = async () => {
  if (!roomCode.value.trim() || !participantName.value.trim()) return

  joining.value = true
  error.value = ''

  const result = await joinRoomMutation.executeMutation({
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
