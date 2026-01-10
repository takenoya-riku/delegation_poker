<template>
  <div class="space-y-6 animate-fade-in">
    <div class="card-modern border-2 border-gray-300 bg-gradient-to-br from-white to-gray-50 shadow-xl">
      <div class="card-body p-6">
        <div class="flex items-center gap-3 mb-6">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-gray-400 to-gray-600 flex items-center justify-center text-white text-xl font-bold shadow-lg">
            ✏️
          </div>
          <h2 class="card-title text-2xl text-gray-800">話し合いたい対象出し</h2>
        </div>
        <form @submit.prevent="handleAddTopic" class="space-y-4">
          <div class="form-control">
            <input
              v-model="newTopicTitle"
              type="text"
              placeholder="トピックタイトル"
              class="input input-bordered w-full focus:input-primary focus:ring-2 focus:ring-gray-400 transition-all duration-300"
              required
            />
          </div>
          <div class="form-control">
            <textarea
              v-model="newTopicDescription"
              class="textarea textarea-bordered w-full focus:ring-2 focus:ring-gray-400 transition-all duration-300"
              placeholder="説明（オプション）"
            ></textarea>
          </div>
          <button type="submit" class="btn-gradient w-full py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300" :disabled="adding">
            <span v-if="adding" class="loading loading-spinner loading-sm mr-2"></span>
            {{ adding ? '追加中...' : '✨ 対象を追加' }}
          </button>
        </form>
        <div v-if="addError" class="alert alert-error mt-4 shadow-md animate-fade-in">
          <span>{{ addError }}</span>
        </div>
      </div>
    </div>

    <div v-if="draftTopics.length === 0" class="card-modern border-2 border-dashed border-gray-300 bg-gray-50 text-center py-12">
      <span class="text-5xl mb-4 block">📝</span>
      <p class="text-gray-600 font-medium">まだ対象が追加されていません</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="(topic, index) in draftTopics"
        :key="topic.id"
        class="card-modern border-2 border-gray-200 bg-white shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-[1.01] animate-fade-in"
        :style="{ animationDelay: `${index * 0.05}s` }"
      >
        <div class="card-body p-5">
          <h3 class="card-title text-xl text-gray-800 mb-2">{{ topic.title }}</h3>
          <p v-if="topic.description" class="text-sm text-gray-600">{{ topic.description }}</p>
        </div>
      </div>
    </div>

    <div v-if="draftTopics.length > 0" class="flex justify-end">
      <button @click="handleStartOrganizing" class="btn-gradient-secondary px-8 py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105" :disabled="organizing">
        <span v-if="organizing" class="loading loading-spinner loading-sm mr-2"></span>
        {{ organizing ? '整理フェーズに移行中...' : '🚀 整理フェーズに進む' }}
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
