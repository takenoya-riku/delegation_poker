<template>
  <div class="card bg-base-100 shadow-xl">
    <div class="card-body">
      <h2 class="card-title">ルームを作成</h2>
      <form @submit.prevent="handleCreate">
        <div class="form-control">
          <label class="label">
            <span class="label-text">ルーム名</span>
          </label>
          <input
            v-model="roomName"
            type="text"
            placeholder="例: プロジェクトAの意思決定"
            class="input input-bordered"
            required
          />
        </div>
        <div class="form-control mt-4">
          <button type="submit" class="btn btn-primary" :disabled="creating">
            {{ creating ? '作成中...' : 'ルームを作成' }}
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
import { CreateRoomDocument } from '~/graphql/generated/types'

const roomName = ref('')
const creating = ref(false)
const error = ref('')

const createRoomMutation = useMutation(CreateRoomDocument)

const handleCreate = async () => {
  if (!roomName.value.trim()) return

  creating.value = true
  error.value = ''

  const result = await createRoomMutation.executeMutation({
    name: roomName.value.trim()
  })

  if (result.data?.createRoom?.room) {
    const code = result.data.createRoom.room.code
    await navigateTo(`/room/${code}`)
  } else {
    error.value = result.data?.createRoom?.errors?.[0] || 'ルームの作成に失敗しました'
  }

  creating.value = false
}
</script>
