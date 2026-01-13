<template>
  <div class="space-y-4">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">
          トピック
        </h2>
        <form
          class="space-y-4"
          @submit.prevent="handleAddTopic"
        >
          <div class="form-control">
            <input
              v-model="newTopicTitle"
              type="text"
              placeholder="トピックタイトル"
              class="input input-bordered px-[5px]"
              required
            >
          </div>
          <div class="form-control">
            <textarea
              v-model="newTopicDescription"
              class="textarea textarea-bordered px-[5px]"
              placeholder="説明（オプション）"
            />
          </div>
          <button
            type="submit"
            class="btn btn-primary"
            :disabled="adding"
          >
            {{ adding ? '追加中...' : 'トピックを追加' }}
          </button>
        </form>
        <div
          v-if="addError"
          class="alert alert-error mt-4"
        >
          <span>{{ addError }}</span>
        </div>
      </div>
    </div>

    <TopicCard
      v-for="topic in topics"
      :key="topic.id"
      :topic="topic"
      :participant-id="participantId"
      @refresh="$emit('refresh')"
    />
  </div>
</template>

<script setup lang="ts">
import { useTopicActions } from '~/composables/useTopicActions'

const props = defineProps<{
  topics: Array<{
    id: string
    title: string
    description: string | null
    status: string
  }>
  roomId: string
  participantId: string | null
}>()

const emit = defineEmits<{
  refresh: []
}>()

const newTopicTitle = ref('')
const newTopicDescription = ref('')
const adding = ref(false)
const addError = ref('')

const { addTopic } = useTopicActions()

const handleAddTopic = async () => {
  if (!newTopicTitle.value.trim()) return
  if (!props.participantId) return

  adding.value = true
  addError.value = ''

  const result = await addTopic({
    roomId: props.roomId,
    participantId: props.participantId,
    title: newTopicTitle.value.trim(),
    description: newTopicDescription.value.trim() || null
  })

  if (result.data?.addTopic?.topic) {
    newTopicTitle.value = ''
    newTopicDescription.value = ''
    emit('refresh')
  } else {
    addError.value = result.data?.addTopic?.errors?.[0] || 'トピックの追加に失敗しました'
  }

  adding.value = false
}
</script>
