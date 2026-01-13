<template>
  <div class="space-y-6 animate-fade-in">
    <div class="card-modern border-2 border-gray-300 bg-gradient-to-br from-white to-gray-50 shadow-xl">
      <div class="card-body p-6">
        <div class="flex items-center gap-3 mb-6">
          <div class="w-12 h-12 rounded-full bg-gradient-to-br from-gray-400 to-gray-600 flex items-center justify-center text-white text-xl font-bold shadow-lg">
            ✏️
          </div>
          <h2 class="card-title text-2xl text-gray-800">
            話し合いたい対象出し
          </h2>
        </div>
        <form
          class="space-y-4"
          @submit.prevent="handleAddTopic"
        >
          <div class="form-control">
            <input
              v-model="newTopicTitle"
              type="text"
              placeholder="トピックタイトル"
              class="input input-bordered w-full px-[5px] focus:input-primary focus:ring-2 focus:ring-gray-400 transition-all duration-300"
              required
            >
          </div>
          <div class="form-control">
            <textarea
              v-model="newTopicDescription"
              class="textarea textarea-bordered w-full px-[5px] focus:ring-2 focus:ring-gray-400 transition-all duration-300"
              placeholder="説明（オプション）"
            />
          </div>
          <button
            type="submit"
            class="btn-gradient w-full py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300"
            :disabled="adding"
          >
            <span
              v-if="adding"
              class="loading loading-spinner loading-sm mr-2"
            />
            {{ adding ? '追加中...' : '✨ 対象を追加' }}
          </button>
        </form>
        <div
          v-if="addError"
          class="alert alert-error mt-4 shadow-md animate-fade-in"
        >
          <span>{{ addError }}</span>
        </div>
      </div>
    </div>

    <div
      v-if="draftTopics.length === 0"
      class="card-modern border-2 border-dashed border-gray-300 bg-gray-50 text-center py-12"
    >
      <span class="text-5xl mb-4 block">📝</span>
      <p class="text-gray-600 font-medium">
        まだ対象が追加されていません
      </p>
    </div>

    <div
      v-else
      class="space-y-4"
    >
      <div
        v-for="(topic, index) in draftTopics"
        :key="topic.id"
        class="card-modern border-2 border-gray-200 bg-white shadow-md hover:shadow-lg transition-all duration-300 transform hover:scale-[1.01] animate-fade-in"
        :style="{ animationDelay: `${index * 0.05}s` }"
      >
        <div class="card-body p-5">
          <h3 class="card-title text-xl text-gray-800 mb-2">
            {{ topic.title }}
          </h3>
          <p
            v-if="topic.description"
            class="text-sm text-gray-600"
          >
            {{ topic.description }}
          </p>
          <p class="text-xs text-gray-500 mt-3">
            作成者: {{ creatorName(topic) }}
          </p>
          <div
            v-if="isOwnTopic(topic)"
            class="card-actions justify-end mt-4"
          >
            <button
              class="btn btn-sm px-4 py-2 rounded-lg bg-white border-2 border-gray-300 text-gray-700 hover:border-gray-400 hover:bg-gray-50 transition-all duration-300 shadow-md hover:shadow-lg"
              @click="openEditModal(topic)"
            >
              編集
            </button>
            <button
              class="btn btn-sm px-4 py-2 rounded-lg bg-gradient-to-r from-red-500 to-pink-500 text-white border-0 hover:from-red-600 hover:to-pink-600 transition-all duration-300 shadow-md hover:shadow-lg"
              :disabled="deleting"
              @click="handleDelete(topic.id)"
            >
              <span
                v-if="deleting"
                class="loading loading-spinner loading-xs mr-1"
              />
              削除
            </button>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="draftTopics.length > 0"
      class="space-y-4"
    >
      <div
        v-if="organizeError"
        class="alert alert-error shadow-md animate-fade-in"
      >
        <span>{{ organizeError }}</span>
      </div>
      <div
        v-if="editError"
        class="alert alert-error shadow-md animate-fade-in"
      >
        <span>{{ editError }}</span>
      </div>
      <div class="flex justify-end">
        <button
          v-if="props.isRoomMaster"
          class="btn-gradient-secondary px-8 py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all duration-300 transform hover:scale-105"
          :disabled="organizing"
          @click="handleStartOrganizing"
        >
          <span
            v-if="organizing"
            class="loading loading-spinner loading-sm mr-2"
          />
          {{ organizing ? '整理フェーズに移行中...' : '🚀 整理フェーズに進む' }}
        </button>
        <span
          v-else
          class="text-sm text-gray-500"
        >整理フェーズへの移行はルームマスターのみ可能です</span>
      </div>
    </div>
  </div>

  <!-- 編集モーダル -->
  <div
    v-if="editingTopic"
    class="modal modal-open"
  >
    <div class="modal-box bg-white shadow-2xl border-2 border-gray-200 rounded-2xl">
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
          class="input input-bordered w-full px-[5px] focus:ring-2 focus:ring-gray-400 transition-all duration-300"
          required
        >
      </div>
      <div class="form-control mb-6">
        <label class="label">
          <span class="label-text font-semibold text-gray-700">説明</span>
        </label>
        <textarea
          v-model="editDescription"
          class="textarea textarea-bordered w-full px-[5px] focus:ring-2 focus:ring-gray-400 transition-all duration-300"
        />
      </div>
      <div class="modal-action">
        <button
          class="btn px-6 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition-all duration-300 shadow-md"
          @click="closeEditModal"
        >
          キャンセル
        </button>
        <button
          class="btn-gradient px-6 py-2 rounded-lg font-semibold shadow-lg hover:shadow-xl transition-all duration-300"
          :disabled="updating"
          @click="handleUpdate"
        >
          <span
            v-if="updating"
            class="loading loading-spinner loading-sm mr-2"
          />
          {{ updating ? '更新中...' : '更新' }}
        </button>
      </div>
    </div>
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
    participantId?: string | null
  }>
  participants: Array<{
    id: string
    name: string
  }>
  roomId: string
  isRoomMaster: boolean
  currentParticipantId: string | null
}>()

const emit = defineEmits<{
  refresh: []
}>()

const draftTopics = computed(() => {
  const topics = props.topics.filter(t => t.status === 'DRAFT' || t.status === 'draft')
  const topicsByCreator = new Map<string | null, typeof topics>()
  const normalizeName = (name: string) => name.trim()
  const sortedParticipants = [...props.participants].sort((a, b) => {
    return normalizeName(a.name).localeCompare(normalizeName(b.name), 'ja')
  })

  topics.forEach(topic => {
    const key = topic.participantId ?? null
    const list = topicsByCreator.get(key) || []
    list.push(topic)
    topicsByCreator.set(key, list)
  })

  const creatorOrder = sortedParticipants
    .map(participant => participant.id)
    .filter(participantId => topicsByCreator.has(participantId))

  if (props.currentParticipantId && creatorOrder.includes(props.currentParticipantId)) {
    const rest = creatorOrder.filter(id => id !== props.currentParticipantId)
    creatorOrder.splice(0, creatorOrder.length, props.currentParticipantId, ...rest)
  }

  const orderedTopics: typeof topics = []
  creatorOrder.forEach(creatorId => {
    const group = topicsByCreator.get(creatorId) || []
    group.sort((a, b) => a.title.localeCompare(b.title, 'ja'))
    orderedTopics.push(...group)
  })

  const unknownGroup = topicsByCreator.get(null) || []
  unknownGroup.sort((a, b) => a.title.localeCompare(b.title, 'ja'))
  orderedTopics.push(...unknownGroup)

  return orderedTopics
})

const newTopicTitle = ref('')
const newTopicDescription = ref('')
const adding = ref(false)
const addError = ref('')
const organizing = ref(false)
const organizeError = ref('')
const editingTopic = ref<typeof props.topics[0] | null>(null)
const editTitle = ref('')
const editDescription = ref('')
const updating = ref(false)
const deleting = ref(false)
const editError = ref('')

const { addTopic, startOrganizing, updateTopic, deleteTopic } = useTopicActions()

const isOwnTopic = (topic: typeof props.topics[0]) => {
  return Boolean(props.currentParticipantId && topic.participantId === props.currentParticipantId)
}

const creatorName = (topic: typeof props.topics[0]) => {
  if (!topic.participantId) return '-'
  return props.participants.find(p => p.id === topic.participantId)?.name || '-'
}

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

const handleAddTopic = async () => {
  if (!newTopicTitle.value.trim()) return
  if (!props.currentParticipantId) {
    addError.value = '参加者情報が見つかりません'
    return
  }

  adding.value = true
  addError.value = ''

  try {
    const result = await addTopic({
      roomId: props.roomId,
      participantId: props.currentParticipantId,
      title: newTopicTitle.value.trim(),
      description: newTopicDescription.value.trim() || null
    })

    // デバッグ用: 結果をログに出力
    console.log('AddTopic result:', result)

    if (result.error) {
      console.error('GraphQL error:', result.error)
      addError.value = result.error.message || 'トピックの追加に失敗しました'
      adding.value = false
      return
    }

    if (!result.data) {
      console.error('No data in result:', result)
      addError.value = 'レスポンスデータがありません'
      adding.value = false
      return
    }

    if (result.data?.addTopic?.topic) {
      newTopicTitle.value = ''
      newTopicDescription.value = ''
      emit('refresh')
    } else {
      const errors = result.data?.addTopic?.errors || []
      console.warn('AddTopic errors:', errors)
      addError.value = errors.length > 0 ? errors[0] : 'トピックの追加に失敗しました'
    }
  } catch (error: any) {
    console.error('Unexpected error:', error)
    console.error('Error stack:', error?.stack)
    // エラーの詳細を表示
    const errorMessage = error?.message || error?.toString() || '予期しないエラーが発生しました'
    addError.value = `エラー: ${errorMessage}`
  } finally {
    adding.value = false
  }
}

const handleStartOrganizing = async () => {
  if (draftTopics.value.length === 0) return

  organizing.value = true
  organizeError.value = ''

  try {
    // すべてのdraftトピックをorganizingに移行
    const promises = draftTopics.value.map(topic =>
      startOrganizing({ topicId: topic.id })
    )

    const results = await Promise.all(promises)

    // エラーをチェック
    const errors = results
      .map((result, index) => {
        if (result.error) {
          return `${draftTopics.value[index].title}: ${result.error.message}`
        }
        if (result.data?.startOrganizing?.errors?.length > 0) {
          return `${draftTopics.value[index].title}: ${result.data.startOrganizing.errors[0]}`
        }
        return null
      })
      .filter(Boolean)

    if (errors.length > 0) {
      organizeError.value = errors.join(', ')
    } else {
      // 成功した場合はリフレッシュ
      emit('refresh')
    }
  } catch (error: any) {
    console.error('Unexpected error:', error)
    organizeError.value = `エラー: ${error?.message || error?.toString() || '予期しないエラーが発生しました'}`
  } finally {
    organizing.value = false
  }
}

const handleUpdate = async () => {
  if (!editingTopic.value) return
  if (!props.currentParticipantId) {
    editError.value = '参加者情報が見つかりません'
    return
  }

  updating.value = true
  editError.value = ''

  const result = await updateTopic({
    topicId: editingTopic.value.id,
    participantId: props.currentParticipantId,
    title: editTitle.value,
    description: editDescription.value || null,
  })

  if (result.data?.updateTopic?.topic) {
    emit('refresh')
    closeEditModal()
  } else {
    editError.value = result.data?.updateTopic?.errors?.[0] || 'トピックの更新に失敗しました'
  }

  updating.value = false
}

const handleDelete = async (topicId: string) => {
  if (!props.currentParticipantId) {
    editError.value = '参加者情報が見つかりません'
    return
  }
  if (!confirm('このトピックを削除しますか？')) return

  deleting.value = true
  editError.value = ''

  const result = await deleteTopic({
    topicId,
    participantId: props.currentParticipantId,
  })

  if (result.data?.deleteTopic?.success) {
    emit('refresh')
  } else {
    editError.value = result.data?.deleteTopic?.errors?.[0] || 'トピックの削除に失敗しました'
  }

  deleting.value = false
}
</script>
