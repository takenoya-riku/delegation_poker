<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">ルームに参加</h2>
      <form @submit.prevent="handleJoin">
        <div class="form-control">
          <label class="label">
            <span class="label-text">ルームコード</span>
          </label>
          <input
            v-model="roomCode"
            type="text"
            placeholder="6桁のコード"
            class="input input-bordered"
            maxlength="6"
            required
          />
        </div>
        <div class="form-control mt-4">
          <label class="label">
            <span class="label-text">あなたの名前</span>
          </label>
          <input
            v-model="participantName"
            type="text"
            placeholder="例: 山田太郎"
            class="input input-bordered"
            required
          />
        </div>
        <div class="form-control mt-4">
          <button type="submit" class="btn btn-primary" :disabled="joining">
            {{ joining ? '参加中...' : 'ルームに参加' }}
          </button>
        </div>
        <div v-if="error" class="alert alert-error mt-4">
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
      localStorage.setItem(`participant_${code}`, participantId)
    }
    await navigateTo(`/room/${code}`)
  } else {
    error.value = result.data?.joinRoom?.errors?.[0] || 'ルームへの参加に失敗しました'
  }

  joining.value = false
}
</script>
