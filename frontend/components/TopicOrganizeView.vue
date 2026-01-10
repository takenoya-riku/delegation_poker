<template>
  <div class="space-y-4">
    <div class="card bg-base-100 shadow-xl">
      <div class="card-body">
        <h2 class="card-title">対象の整理</h2>
        <p class="text-sm text-gray-600">重複や類似の対象を統合・整理してください</p>
      </div>
    </div>

    <div v-if="organizingTopics.length === 0" class="alert alert-info">
      <span>整理する対象がありません</span>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="topic in organizingTopics"
        :key="topic.id"
        class="card bg-base-100 shadow"
      >
        <div class="card-body">
          <h3 class="card-title text-lg">{{ topic.title }}</h3>
          <p v-if="topic.description" class="text-sm text-gray-600">{{ topic.description }}</p>
          <div class="card-actions justify-end mt-4">
            <button @click="openEditModal(topic)" class="btn btn-sm btn-outline">編集</button>
            <button @click="handleDelete(topic.id)" class="btn btn-sm btn-error" :disabled="deleting">
              削除
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="organizingTopics.length > 0" class="flex justify-end">
      <button @click="handleStartVoting" class="btn btn-primary" :disabled="starting">
        {{ starting ? '投票フェーズに移行中...' : '現状確認投票に進む' }}
      </button>
    </div>

    <!-- 編集モーダル -->
    <div v-if="editingTopic" class="modal modal-open">
      <div class="modal-box">
        <h3 class="font-bold text-lg mb-4">トピックを編集</h3>
        <div class="form-control mb-4">
          <label class="label">
            <span class="label-text">タイトル</span>
          </label>
          <input
            v-model="editTitle"
            type="text"
            class="input input-bordered"
            required
          />
        </div>
        <div class="form-control mb-4">
          <label class="label">
            <span class="label-text">説明</span>
          </label>
          <textarea
            v-model="editDescription"
            class="textarea textarea-bordered"
          ></textarea>
        </div>
        <div class="modal-action">
          <button @click="closeEditModal" class="btn">キャンセル</button>
          <button @click="handleUpdate" class="btn btn-primary" :disabled="updating">
            {{ updating ? '更新中...' : '更新' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import { UpdateTopicDocument, DeleteTopicDocument, OrganizeTopicDocument } from '~/graphql/generated/types'

const props = defineProps<{
  topics: Array<{
    id: string
    title: string
    description: string | null
    status: string
  }>
}>()

const emit = defineEmits<{
  refresh: []
}>()

const organizingTopics = computed(() => props.topics.filter(t => t.status === 'organizing'))

const deleting = ref(false)
const starting = ref(false)
const editingTopic = ref<typeof props.topics[0] | null>(null)
const editTitle = ref('')
const editDescription = ref('')
const updating = ref(false)

const openEditModal = (topic: typeof props.topics[0]) => {
  editingTopic.value = topic
  editTitle.value = topic.title
  editDescription.value = topic.description || ''
}

const closeEditModal = () => {
  editingTopic.value = null
  editTitle.value = ''
  editDescription.value = ''
}

const updateTopicMutation = useMutation(UpdateTopicDocument)
const deleteTopicMutation = useMutation(DeleteTopicDocument)
const organizeTopicMutation = useMutation(OrganizeTopicDocument)

const handleDelete = async (topicId: string) => {
  if (!confirm('このトピックを削除しますか？')) return

  deleting.value = true
  const result = await deleteTopicMutation.executeMutation({ topicId })
  if (result.data?.deleteTopic?.success) {
    emit('refresh')
  }
  deleting.value = false
}

const handleUpdate = async () => {
  if (!editingTopic.value) return

  updating.value = true
  const result = await updateTopicMutation.executeMutation({
    topicId: editingTopic.value.id,
    title: editTitle.value,
    description: editDescription.value || null
  })
  if (result.data?.updateTopic?.topic) {
    emit('refresh')
    closeEditModal()
  }
  updating.value = false
}

const handleStartVoting = async () => {
  starting.value = true
  // すべてのorganizingトピックに対してorganizeTopicを呼び出す
  const promises = organizingTopics.value.map(topic =>
    organizeTopicMutation.executeMutation({ topicId: topic.id })
  )
  await Promise.all(promises)
  emit('refresh')
  starting.value = false
}
</script>
