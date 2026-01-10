<template>
  <div class="space-y-4">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">話し合いたい対象出し</h2>
        <form @submit.prevent="handleAddTopic" class="space-y-4">
          <div class="form-control">
            <input
              v-model="newTopicTitle"
              type="text"
              placeholder="トピックタイトル"
              class="input input-bordered"
              required
            />
          </div>
          <div class="form-control">
            <textarea
              v-model="newTopicDescription"
              class="textarea textarea-bordered"
              placeholder="説明（オプション）"
            ></textarea>
          </div>
          <button type="submit" class="btn btn-primary" :disabled="adding">
            {{ adding ? '追加中...' : '対象を追加' }}
          </button>
        </form>
        <div v-if="addError" class="alert alert-error mt-4">
          <span>{{ addError }}</span>
        </div>
      </div>
    </div>

    <div v-if="draftTopics.length === 0" class="alert alert-info">
      <span>まだ対象が追加されていません</span>
    </div>

    <div v-else class="space-y-2">
      <div
        v-for="topic in draftTopics"
        :key="topic.id"
        class="card bg-base-100 shadow"
      >
        <div class="card-body">
          <h3 class="card-title text-lg">{{ topic.title }}</h3>
          <p v-if="topic.description" class="text-sm text-gray-600">{{ topic.description }}</p>
        </div>
      </div>
    </div>

    <div v-if="draftTopics.length > 0" class="flex justify-end">
      <button @click="handleStartOrganizing" class="btn btn-primary" :disabled="organizing">
        {{ organizing ? '整理フェーズに移行中...' : '整理フェーズに進む' }}
      </button>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { AddTopicDocument } from '~/graphql/generated/types'

const props = defineProps<{
  topics: Array<{
    id: string
    title: string
    description: string | null
    status: string
  }>
  roomId: string
}>()

const emit = defineEmits<{
  refresh: []
}>()

const draftTopics = computed(() => props.topics.filter(t => t.status === 'draft'))

const newTopicTitle = ref('')
const newTopicDescription = ref('')
const adding = ref(false)
const addError = ref('')
const organizing = ref(false)

const addTopicMutation = useMutation(AddTopicDocument)

const handleAddTopic = async () => {
  if (!newTopicTitle.value.trim()) return

  adding.value = true
  addError.value = ''

  const result = await addTopicMutation.executeMutation({
    roomId: props.roomId,
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

const handleStartOrganizing = async () => {
  organizing.value = true
  // すべてのdraftトピックをorganizingに移行
  // 実際の実装では、各トピックに対してorganizeTopic mutationを呼び出す必要があります
  // ここでは簡易的にrefreshを発火
  emit('refresh')
  organizing.value = false
}
</script>
