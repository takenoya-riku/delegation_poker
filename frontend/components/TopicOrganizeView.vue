<template>
  <div class="space-y-6 animate-fade-in">
    <div class="card-modern border-2 border-yellow-300 bg-gradient-to-br from-white to-yellow-50 shadow-xl">
      <div class="card-body p-6">
        <div class="flex items-center gap-3 mb-3">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-yellow-400 to-orange-500 flex items-center justify-center text-white text-xl font-bold shadow-lg">
            🔧
          </div>
          <h2 class="card-title text-2xl text-gray-800">対象の整理</h2>
        </div>
        <p class="text-sm text-gray-600 ml-16">重複や類似の対象を統合・整理してください</p>
      </div>
    </div>

    <div v-if="organizingTopics.length === 0" class="card-modern border-2 border-dashed border-yellow-300 bg-yellow-50 text-center py-12">
      <span class="text-5xl mb-4 block">📋</span>
      <p class="text-gray-600 font-medium">整理する対象がありません</p>
    </div>

    <div v-else class="space-y-4">
      <div
        v-for="(topic, index) in organizingTopics"
        :key="topic.id"
        class="card-modern border-2 border-yellow-200 bg-gradient-to-r from-white to-yellow-50 shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-[1.01] animate-fade-in"
        :style="{ animationDelay: `${index * 0.05}s` }"
      >
        <div class="card-body p-5">
          <h3 class="card-title text-xl text-gray-800 mb-2">{{ topic.title }}</h3>
          <p v-if="topic.description" class="text-sm text-gray-600 mb-4">{{ topic.description }}</p>
          <div class="card-actions justify-end">
            <button @click="openEditModal(topic)" class="btn btn-sm px-4 py-2 rounded-lg bg-white border-2 border-gray-300 text-gray-700 hover:border-gray-400 hover:bg-gray-50 transition-all duration-300 shadow-md hover:shadow-lg">編集</button>
            <button @click="handleDelete(topic.id)" class="btn btn-sm px-4 py-2 rounded-lg bg-gradient-to-r from-red-500 to-pink-500 text-white border-0 hover:from-red-600 hover:to-pink-600 transition-all duration-300 shadow-md hover:shadow-lg" :disabled="deleting">
              <span v-if="deleting" class="loading loading-spinner loading-xs mr-1"></span>
              削除
            </button>
          </div>
        </div>
      </div>
    </div>

    <div v-if="organizingTopics.length > 0" class="space-y-3">
      <div v-if="revertError" class="alert alert-error shadow-md animate-fade-in">
        <span>{{ revertError }}</span>
      </div>
      <div class="flex flex-col gap-3 sm:flex-row sm:justify-end">
        <template v-if="props.isRoomMaster">
          <button
            @click="handleRevertToDraft"
            class="btn px-8 py-3 rounded-xl font-semibold shadow-lg border-2 border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-all duration-300 transform hover:scale-105"
            :disabled="reverting"
          >
            <span v-if="reverting" class="loading loading-spinner loading-sm mr-2"></span>
            {{ reverting ? '対象出しに戻しています...' : '↩️ 対象出しに戻す' }}
          </button>
          <button
            @click="handleStartVoting"
            class="btn-gradient px-8 py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105"
            :disabled="starting"
          >
            <span v-if="starting" class="loading loading-spinner loading-sm mr-2"></span>
            {{ starting ? '投票フェーズに移行中...' : '📊 現状確認投票に進む' }}
          </button>
        </template>
        <span v-else class="text-sm text-gray-500">投票フェーズへの移行はルームマスターのみ可能です</span>
      </div>
    </div>

    <!-- 編集モーダル -->
    <div v-if="editingTopic" class="modal modal-open">
      <div class="modal-box bg-white shadow-2xl border-2 border-yellow-200 rounded-2xl">
        <h3 class="font-bold text-xl mb-6 text-gray-800 flex items-center gap-2">
          <span class="text-2xl">✏️</span>
          トピックを編集
        </h3>
        <div class="form-control mb-4">
          <label class="label">
            <span class="label-text font-semibold text-gray-700">タイトル</span>
          </label>
          <input
            v-model="editTitle"
            type="text"
            class="input input-bordered w-full px-[5px] focus:ring-2 focus:ring-yellow-400 transition-all duration-300"
            required
          />
        </div>
        <div class="form-control mb-6">
          <label class="label">
            <span class="label-text font-semibold text-gray-700">説明</span>
          </label>
          <textarea
            v-model="editDescription"
            class="textarea textarea-bordered w-full px-[5px] focus:ring-2 focus:ring-yellow-400 transition-all duration-300"
          ></textarea>
        </div>
        <div class="modal-action">
          <button @click="closeEditModal" class="btn px-6 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition-all duration-300 shadow-md">キャンセル</button>
          <button @click="handleUpdate" class="btn-gradient px-6 py-2 rounded-lg font-semibold shadow-lg hover:shadow-xl transition-all duration-300" :disabled="updating">
            <span v-if="updating" class="loading loading-spinner loading-sm mr-2"></span>
            {{ updating ? '更新中...' : '更新' }}
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useMutation } from '@urql/vue'
import gql from 'graphql-tag'
import { UpdateTopicDocument, DeleteTopicDocument, OrganizeTopicDocument } from '~/graphql/generated/types'

const props = defineProps<{
  topics: Array<{
    id: string
    title: string
    description: string | null
    status: string
    participantId?: string | null
  }>
  isRoomMaster: boolean
  currentParticipantId: string | null
}>()

const emit = defineEmits<{
  refresh: []
}>()

const organizingTopics = computed(() => props.topics.filter(t => t.status === 'ORGANIZING' || t.status === 'organizing'))

const deleting = ref(false)
const starting = ref(false)
const reverting = ref(false)
const revertError = ref('')
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
const revertToDraftMutation = useMutation(gql`
  mutation RevertToDraft($topicId: ID!) {
    revertToDraft(topicId: $topicId) {
      topic {
        id
        status
      }
      errors
    }
  }
`)

const handleDelete = async (topicId: string) => {
  if (!props.currentParticipantId) return
  if (!confirm('このトピックを削除しますか？')) return

  deleting.value = true
  const result = await deleteTopicMutation.executeMutation({
    topicId,
    participantId: props.currentParticipantId,
  })
  if (result.data?.deleteTopic?.success) {
    emit('refresh')
  }
  deleting.value = false
}

const handleUpdate = async () => {
  if (!editingTopic.value) return
  if (!props.currentParticipantId) return

  updating.value = true
  const result = await updateTopicMutation.executeMutation({
    topicId: editingTopic.value.id,
    participantId: props.currentParticipantId,
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

const handleRevertToDraft = async () => {
  if (organizingTopics.value.length === 0) return
  if (!confirm('整理フェーズを取り消して対象出しに戻しますか？')) return

  reverting.value = true
  revertError.value = ''

  const results = await Promise.all(
    organizingTopics.value.map(topic =>
      revertToDraftMutation.executeMutation({ topicId: topic.id })
    )
  )

  const errors = results
    .map((result, index) => {
      if (result.error) {
        return `${organizingTopics.value[index].title}: ${result.error.message}`
      }
      if (result.data?.revertToDraft?.errors?.length > 0) {
        return `${organizingTopics.value[index].title}: ${result.data.revertToDraft.errors[0]}`
      }
      return null
    })
    .filter(Boolean)

  if (errors.length > 0) {
    revertError.value = errors.join(', ')
  } else {
    emit('refresh')
  }

  reverting.value = false
}
</script>
