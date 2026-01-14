<template>
  <div class="space-y-6">
    <div class="sticky top-0 z-20">
      <div class="card-modern border-2 border-blue-200 bg-white/95 shadow-xl backdrop-blur">
        <div class="card-body p-6">
          <div class="grid grid-cols-7 gap-2 text-center text-xs text-gray-600">
            <div
              v-for="level in delegationLevels"
              :key="level.level"
              class="space-y-1"
            >
              <div class="flex items-center justify-center">
                <img
                  :src="level.image"
                  :alt="`権限レベル${level.level}`"
                  class="h-56 w-auto"
                  loading="lazy"
                >
              </div>
              <div class="text-lg font-semibold text-gray-700">
                Lv{{ level.level }}
              </div>
              <div class="text-sm">
                {{ level.label }}
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div class="space-y-5">
      <div class="flex flex-wrap items-center justify-between gap-3">
        <div>
          <button
            v-if="isRoomMaster && orderedTopics.length > 0"
            class="btn px-6 py-2 rounded-xl font-semibold shadow-lg border-2 border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-all duration-300"
            :disabled="revertingToOrganizing"
            @click="handleRevertToOrganizing"
          >
            <span
              v-if="revertingToOrganizing"
              class="loading loading-spinner loading-sm mr-2"
            />
            {{ revertingToOrganizing ? '整理フェーズに戻しています...' : '↩️ 整理フェーズに戻す' }}
          </button>
        </div>
        <div>
          <button
            class="btn px-6 py-2 rounded-xl font-semibold shadow-lg border-2 border-gray-300 bg-white text-gray-700 hover:bg-gray-50 hover:border-gray-400 transition-all duration-300"
            @click="exportVotesCsv"
          >
            📄 CSVを出力
          </button>
        </div>
      </div>
      <div
        v-if="revertError"
        class="alert alert-error shadow-md"
      >
        <span>{{ revertError }}</span>
      </div>
      <div
        v-for="topic in orderedTopics"
        :key="topic.id"
        class="card-modern border-2 border-blue-100 bg-white/80 shadow-lg"
      >
        <div class="card-body p-6 space-y-5">
          <div class="flex flex-col gap-4 lg:flex-row lg:items-start lg:justify-between">
            <div class="flex-1 space-y-2">
              <h3 class="text-xl font-bold text-gray-800">
                {{ topic.title }}
              </h3>
              <p
                v-if="topic.description"
                class="text-sm text-gray-600"
              >
                {{ topic.description }}
              </p>
              <div class="flex flex-wrap gap-2 pt-2">
                <button
                  class="px-4 py-2 rounded-full text-sm font-semibold shadow-md"
                  :class="voteButtonClass('current', topic)"
                  :disabled="!canVoteCurrent(topic) || isVoteLockedCurrent(topic)"
                  @click="openVoteModal(topic, 'current_state')"
                >
                  {{ currentVoteButtonLabel(topic) }}
                </button>
                <button
                  class="px-4 py-2 rounded-full text-sm font-semibold shadow-md"
                  :class="voteButtonClass('desired', topic)"
                  :disabled="!canVoteDesired(topic) || isVoteLockedDesired(topic)"
                  @click="openVoteModal(topic, 'desired_state')"
                >
                  {{ desiredVoteButtonLabel(topic) }}
                </button>
                <span
                  class="badge badge-lg px-3 py-2 text-xs font-semibold"
                  :class="statusBadgeClass(topic)"
                >
                  {{ statusLabel(topic) }}
                </span>
              </div>
              <p
                v-if="voteHint(topic)"
                class="text-xs text-gray-500"
              >
                {{ voteHint(topic) }}
              </p>
            </div>

            <div class="flex flex-col gap-2 lg:min-w-[220px]">
              <button
                v-if="canRevealCurrent(topic)"
                class="btn-gradient-secondary w-full px-4 py-2 rounded-xl text-sm font-semibold shadow-md"
                :disabled="isActionLoading(topic.id, 'reveal_current')"
                @click="handleRevealCurrent(topic)"
              >
                <span
                  v-if="isActionLoading(topic.id, 'reveal_current')"
                  class="loading loading-spinner loading-sm mr-2"
                />
                現状結果を公開
              </button>
              <button
                v-if="canStartDesired(topic)"
                class="btn-gradient w-full px-4 py-2 rounded-xl text-sm font-semibold shadow-md"
                :disabled="isActionLoading(topic.id, 'start_desired')"
                @click="handleStartDesired(topic)"
              >
                <span
                  v-if="isActionLoading(topic.id, 'start_desired')"
                  class="loading loading-spinner loading-sm mr-2"
                />
                ありたい姿投票を開始
              </button>
              <button
                v-if="canRevealDesired(topic)"
                class="btn-gradient-secondary w-full px-4 py-2 rounded-xl text-sm font-semibold shadow-md"
                :disabled="isActionLoading(topic.id, 'reveal_desired')"
                @click="handleRevealDesired(topic)"
              >
                <span
                  v-if="isActionLoading(topic.id, 'reveal_desired')"
                  class="loading loading-spinner loading-sm mr-2"
                />
                理想結果を公開
              </button>
            </div>
          </div>

          <div class="space-y-4">
            <div>
              <div class="flex items-center gap-2 mb-1 text-sm font-semibold text-blue-700">
                <span>現状</span>
                <span class="text-xs text-gray-500">({{ currentVotes(topic).length }}/{{ totalParticipants }})</span>
              </div>
              <p
                v-if="!hasAllVotes(topic, 'current_state')"
                class="text-xs text-blue-400 mb-2"
              >
                全員の投票を待っています
              </p>
              <div class="grid grid-cols-7 overflow-hidden rounded-xl border-2 border-blue-100 bg-white shadow-inner">
                <div
                  v-for="level in delegationLevels"
                  :key="`current-cell-${topic.id}-${level.level}`"
                  class="relative flex h-16 items-center justify-center border-r border-blue-100 bg-gradient-to-b from-blue-50 to-white last:border-r-0"
                >
                  <span class="absolute left-2 top-2 inline-flex h-5 w-5 items-center justify-center rounded-full bg-blue-600 text-[10px] font-semibold text-white shadow-sm">
                    {{ level.level }}
                  </span>
                  <template v-if="currentPinsByLevel(topic, level.level).length > 0">
                    <span
                      v-for="pin in currentPinsByLevel(topic, level.level)"
                      :key="pin.id"
                      class="mx-0.5 inline-flex h-6 w-6 items-center justify-center rounded-full border-2 border-white bg-blue-500 text-[10px] font-semibold text-white shadow-lg"
                      :title="pin.participantName"
                    >
                      {{ pin.participantInitial }}
                    </span>
                  </template>
                  <span
                    v-else
                    class="text-xs text-blue-300"
                  >-</span>
                </div>
              </div>
            </div>

            <div>
              <div class="flex items-center gap-2 mb-1 text-sm font-semibold text-pink-700">
                <span>理想</span>
                <span class="text-xs text-gray-500">({{ desiredVotes(topic).length }}/{{ totalParticipants }})</span>
              </div>
              <p
                v-if="!hasAllVotes(topic, 'desired_state')"
                class="text-xs text-pink-400 mb-2"
              >
                全員の投票を待っています
              </p>
              <div class="grid grid-cols-7 overflow-hidden rounded-xl border-2 border-pink-100 bg-white shadow-inner">
                <div
                  v-for="level in delegationLevels"
                  :key="`desired-cell-${topic.id}-${level.level}`"
                  class="relative flex h-16 items-center justify-center border-r border-pink-100 bg-gradient-to-b from-pink-50 to-white last:border-r-0"
                >
                  <span class="absolute left-2 top-2 inline-flex h-5 w-5 items-center justify-center rounded-full bg-pink-600 text-[10px] font-semibold text-white shadow-sm">
                    {{ level.level }}
                  </span>
                  <template v-if="desiredPinsByLevel(topic, level.level).length > 0">
                    <span
                      v-for="pin in desiredPinsByLevel(topic, level.level)"
                      :key="pin.id"
                      class="mx-0.5 inline-flex h-6 w-6 items-center justify-center rounded-full border-2 border-white bg-pink-500 text-[10px] font-semibold text-white shadow-lg"
                      :title="pin.participantName"
                    >
                      {{ pin.participantInitial }}
                    </span>
                  </template>
                  <span
                    v-else
                    class="text-xs text-pink-300"
                  >-</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>

    <div
      v-if="isVoteModalOpen"
      class="modal modal-open"
    >
      <div class="modal-box bg-white shadow-2xl border-2 border-blue-200 rounded-2xl">
        <h3 class="font-bold text-xl mb-4 text-gray-800">
          {{ modalTitle }}
        </h3>
        <VoteCard
          v-if="selectedTopic && participantId"
          :topic-id="selectedTopic.id"
          :participant-id="participantId"
          :vote-type="selectedVoteType"
          :votes="selectedTopic.votes"
          @voted="handleVoted"
        />
        <div
          v-else
          class="alert alert-info shadow-md"
        >
          <span>投票するにはルームに参加してください</span>
        </div>
        <div class="modal-action">
          <button
            class="btn px-6 py-2 rounded-lg bg-gray-100 text-gray-700 hover:bg-gray-200 transition-all duration-300 shadow-md"
            @click="closeVoteModal"
          >
            閉じる
          </button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useVoteActions } from '~/composables/useVoteActions'

type VoteTypeKey = 'current_state' | 'desired_state'
type TopicVote = {
  id: string
  level: number
  voteType: string
  participant: {
    id: string
    name: string
  }
}

const props = defineProps<{
  topics: Array<{
    id: string
    title: string
    description: string | null
    status: string
    participantId?: string | null
    votes: TopicVote[]
  }>
  participants: Array<{
    id: string
    name: string
  }>
  participantId: string | null
  totalParticipants: number
  isRoomMaster: boolean
  teamName?: string | null
}>()

const emit = defineEmits<{
  refresh: []
}>()

const delegationLevels = [
  {
    level: 1,
    label: '指示',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 1.png', import.meta.url).href,
  },
  {
    level: 2,
    label: '説得',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 2.png', import.meta.url).href,
  },
  {
    level: 3,
    label: '相談',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 3.png', import.meta.url).href,
  },
  {
    level: 4,
    label: '合意',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 4.png', import.meta.url).href,
  },
  {
    level: 5,
    label: '助言',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 5.png', import.meta.url).href,
  },
  {
    level: 6,
    label: '確認',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 6.png', import.meta.url).href,
  },
  {
    level: 7,
    label: '委任',
    image: new URL('~/assets/images/Delegation Poker 2015 professional front (Japanese) - Card 7.png', import.meta.url).href,
  },
]

const normalizeStatus = (status: string) => status.toLowerCase()

const statusLabel = (topic: { status: string }) => {
  const status = normalizeStatus(topic.status)
  const labels: Record<string, string> = {
    current_voting: '現状確認投票中',
    current_revealed: '現状結果公開済み',
    desired_voting: '理想投票中',
    desired_revealed: '理想結果公開済み',
    completed: '完了',
  }
  return labels[status] || topic.status
}

const statusBadgeClass = (topic: { status: string }) => {
  const status = normalizeStatus(topic.status)
  const classes: Record<string, string> = {
    current_voting: 'badge-info',
    current_revealed: 'badge-success',
    desired_voting: 'badge-primary',
    desired_revealed: 'badge-secondary',
    completed: 'badge-ghost',
  }
  return classes[status] || 'badge-outline'
}

const normalizeVoteType = (value: string) => value.toLowerCase()

const votesForType = (topic: { votes: TopicVote[] }, voteType: VoteTypeKey) => {
  return topic.votes.filter(vote => normalizeVoteType(vote.voteType) === voteType)
}

const currentVotes = (topic: { votes: TopicVote[] }) => votesForType(topic, 'current_state')
const desiredVotes = (topic: { votes: TopicVote[] }) => votesForType(topic, 'desired_state')

const hasVoted = (topic: { votes: TopicVote[] }, voteType: VoteTypeKey) => {
  if (!props.participantId) return false
  return votesForType(topic, voteType).some(vote => vote.participant.id === props.participantId)
}

const hasVotedCurrent = (topic: { votes: TopicVote[] }) => hasVoted(topic, 'current_state')
const hasVotedDesired = (topic: { votes: TopicVote[] }) => hasVoted(topic, 'desired_state')

const hasAllVotes = (topic: { votes: TopicVote[] }, voteType: VoteTypeKey) => {
  if (!props.totalParticipants) return false
  return votesForType(topic, voteType).length >= props.totalParticipants
}

const buildPins = (topic: { votes: TopicVote[] }, voteType: VoteTypeKey) => {
  const votes = votesForType(topic, voteType)
  const buckets = new Map<number, TopicVote[]>()
  votes.forEach(vote => {
    const list = buckets.get(vote.level) || []
    list.push(vote)
    buckets.set(vote.level, list)
  })

  const pins: Array<{
    id: string
    level: number
    participantId: string
    participantName: string
    participantInitial: string
    offset: number
  }> = []

  delegationLevels.forEach(({ level }) => {
    const list = buckets.get(level) || []
    list.forEach((vote, index) => {
      const offset = (index - (list.length - 1) / 2) * 8
      pins.push({
        id: `${vote.id}-${vote.voteType}`,
        level,
        participantId: vote.participant.id,
        participantName: vote.participant.name,
        participantInitial: vote.participant.name?.slice(0, 1) || '•',
        offset,
      })
    })
  })

  return pins
}

const currentPins = (topic: { votes: TopicVote[] }) => buildPins(topic, 'current_state')
const desiredPins = (topic: { votes: TopicVote[] }) => buildPins(topic, 'desired_state')

const currentPinsForDisplay = (topic: { status: string; votes: TopicVote[] }) => {
  const status = normalizeStatus(topic.status)
  const revealed = ['current_revealed', 'desired_voting', 'desired_revealed', 'completed'].includes(status)
  if (revealed) return currentPins(topic)
  if (!props.participantId) return []
  return currentPins(topic).filter(pin => pin.participantId === props.participantId)
}

const desiredPinsForDisplay = (topic: { status: string; votes: TopicVote[] }) => {
  const status = normalizeStatus(topic.status)
  const revealed = ['desired_revealed', 'completed'].includes(status)
  if (revealed) return desiredPins(topic)
  if (!props.participantId) return []
  return desiredPins(topic).filter(pin => pin.participantId === props.participantId)
}

const currentPinsByLevel = (topic: { status: string; votes: TopicVote[] }, level: number) => {
  return currentPinsForDisplay(topic).filter(pin => pin.level === level)
}
const desiredPinsByLevel = (topic: { status: string; votes: TopicVote[] }, level: number) => {
  return desiredPinsForDisplay(topic).filter(pin => pin.level === level)
}

const canVoteCurrent = (topic: { status: string }) => {
  return Boolean(props.participantId) && normalizeStatus(topic.status) === 'current_voting'
}

const canVoteDesired = (topic: { status: string }) => {
  return Boolean(props.participantId) && normalizeStatus(topic.status) === 'desired_voting'
}

const voteHint = (topic: { status: string }) => {
  const status = normalizeStatus(topic.status)
  if (status === 'current_voting') return '現状投票を進めてください'
  if (status === 'current_revealed') return '現状結果が公開されました。理想投票を開始してください'
  if (status === 'desired_voting') return '理想投票を進めてください'
  if (status === 'desired_revealed') return '理想投票が公開済みです'
  return ''
}

const isVoteLockedCurrent = (topic: { status: string }) => {
  const status = normalizeStatus(topic.status)
  return ['current_revealed', 'desired_voting', 'desired_revealed', 'completed'].includes(status)
}

const isVoteLockedDesired = (topic: { status: string }) => {
  const status = normalizeStatus(topic.status)
  return ['desired_revealed', 'completed'].includes(status)
}

const voteButtonClass = (kind: 'current' | 'desired', topic: { status: string }) => {
  const locked = kind === 'current' ? isVoteLockedCurrent(topic) : isVoteLockedDesired(topic)
  if (locked) {
    return 'bg-gray-200 text-gray-500 border border-gray-300 cursor-not-allowed'
  }
  return kind === 'current' ? 'btn-gradient-secondary' : 'btn-gradient'
}

const currentVoteButtonLabel = (topic: { votes: TopicVote[]; status: string }) => {
  if (isVoteLockedCurrent(topic)) return '現状投票（締切）'
  if (hasVotedCurrent(topic)) return '現状投票（変更可）'
  return '現状投票'
}

const desiredVoteButtonLabel = (topic: { votes: TopicVote[]; status: string }) => {
  if (isVoteLockedDesired(topic)) return '理想投票（締切）'
  if (hasVotedDesired(topic)) return '理想投票（変更可）'
  return '理想投票'
}

const canRevealCurrent = (topic: { status: string; votes: TopicVote[] }) => {
  return props.isRoomMaster && normalizeStatus(topic.status) === 'current_voting' && hasAllVotes(topic, 'current_state')
}

const canStartDesired = (topic: { status: string }) => {
  return props.isRoomMaster && normalizeStatus(topic.status) === 'current_revealed'
}

const canRevealDesired = (topic: { status: string; votes: TopicVote[] }) => {
  return props.isRoomMaster && normalizeStatus(topic.status) === 'desired_voting' && hasAllVotes(topic, 'desired_state')
}

const isVoteModalOpen = ref(false)
const selectedTopic = ref<null | {
  id: string
  title: string
  votes: TopicVote[]
}>(null)
const selectedVoteType = ref<VoteTypeKey>('current_state')

const modalTitle = computed(() => {
  if (!selectedTopic.value) return '投票'
  return `${selectedTopic.value.title} - ${selectedVoteType.value === 'current_state' ? '現状投票' : '理想投票'}`
})

const openVoteModal = (topic: { id: string; title: string; votes: TopicVote[] }, voteType: VoteTypeKey) => {
  selectedTopic.value = topic
  selectedVoteType.value = voteType
  isVoteModalOpen.value = true
}

const closeVoteModal = () => {
  isVoteModalOpen.value = false
}

const handleVoted = () => {
  closeVoteModal()
  emit('refresh')
}

type ActionType = 'reveal_current' | 'start_desired' | 'reveal_desired'
const actionLoading = ref<{ topicId: string; action: ActionType } | null>(null)

const isActionLoading = (topicId: string, action: ActionType) => {
  return actionLoading.value?.topicId === topicId && actionLoading.value?.action === action
}

const { revealCurrentState, startDesiredStateVoting, revealDesiredState, revertToOrganizing } = useVoteActions()

const revertingToOrganizing = ref(false)
const revertError = ref('')

const handleRevealCurrent = async (topic: { id: string }) => {
  actionLoading.value = { topicId: topic.id, action: 'reveal_current' }
  const result = await revealCurrentState({ topicId: topic.id })
  if (result.data?.revealCurrentState?.topic) {
    emit('refresh')
  }
  actionLoading.value = null
}

const handleStartDesired = async (topic: { id: string }) => {
  actionLoading.value = { topicId: topic.id, action: 'start_desired' }
  const result = await startDesiredStateVoting({ topicId: topic.id })
  if (result.data?.startDesiredStateVoting?.topic) {
    emit('refresh')
  }
  actionLoading.value = null
}

const handleRevealDesired = async (topic: { id: string }) => {
  actionLoading.value = { topicId: topic.id, action: 'reveal_desired' }
  const result = await revealDesiredState({ topicId: topic.id })
  if (result.data?.revealDesiredState?.topic) {
    emit('refresh')
  }
  actionLoading.value = null
}

const handleRevertToOrganizing = async () => {
  if (orderedTopics.value.length === 0) return
  if (!confirm('投票フェーズを取り消して整理フェーズに戻しますか？投票データが失われますがよろしいですか。')) return

  revertingToOrganizing.value = true
  revertError.value = ''

  const results = await Promise.all(
    orderedTopics.value.map(topic => revertToOrganizing({ topicId: topic.id }))
  )

  const errors = results
    .map((result, index) => {
      if (result.error) {
        return `${orderedTopics.value[index].title}: ${result.error.message}`
      }
      if (result.data?.revertToOrganizing?.errors?.length > 0) {
        return `${orderedTopics.value[index].title}: ${result.data.revertToOrganizing.errors[0]}`
      }
      return null
    })
    .filter(Boolean)

  if (errors.length > 0) {
    revertError.value = errors.join(', ')
  } else {
    emit('refresh')
  }

  revertingToOrganizing.value = false
}

const orderedTopics = computed(() => {
  const topicsByCreator = new Map<string | null, typeof props.topics>()
  props.topics.forEach(topic => {
    const key = topic.participantId ?? null
    const list = topicsByCreator.get(key) || []
    list.push(topic)
    topicsByCreator.set(key, list)
  })

  const creatorOrder = props.participants
    .map(participant => participant.id)
    .filter(participantId => topicsByCreator.has(participantId))

  const ordered: typeof props.topics = []
  creatorOrder.forEach(creatorId => {
    const group = topicsByCreator.get(creatorId) || []
    group.sort((a, b) => a.title.localeCompare(b.title, 'ja'))
    ordered.push(...group)
  })

  const unknownGroup = topicsByCreator.get(null) || []
  unknownGroup.sort((a, b) => a.title.localeCompare(b.title, 'ja'))
  ordered.push(...unknownGroup)

  return ordered
})

const exportVotesCsv = () => {
  const header = [
    'トピックタイトル',
    'トピック説明',
    '投票種別',
    '参加者名',
    '投票レベル',
  ]

  const voteTypeLabel = (voteType: string) => {
    const normalized = voteType.toLowerCase()
    if (normalized === 'current_state') return '現状'
    if (normalized === 'desired_state') return '理想'
    return voteType
  }

  const rows = orderedTopics.value.flatMap(topic => {
    return topic.votes.map(vote => [
      topic.title,
      topic.description || '',
      voteTypeLabel(vote.voteType),
      vote.participant.name,
      String(vote.level),
    ])
  })

  const escapeCsv = (value: string) => {
    const needsQuote = value.includes(',') || value.includes('\n') || value.includes('"')
    const escaped = value.replace(/"/g, '""')
    return needsQuote ? `"${escaped}"` : escaped
  }

  const lines = [header, ...rows].map(columns => columns.map(escapeCsv).join(','))
  const csv = `${lines.join('\n')}\n`
  const sanitizedTeamName = (props.teamName || '')
    .trim()
    .replace(/[\\/:*?"<>|]/g, '')
    .replace(/\s+/g, '-')
  const filePrefix = sanitizedTeamName ? `${sanitizedTeamName}-` : ''
  const blob = new Blob([csv], { type: 'text/csv;charset=utf-8;' })
  const url = URL.createObjectURL(blob)
  const link = document.createElement('a')
  link.href = url
  link.download = `delegation-poker-votes-${filePrefix}${new Date().toISOString()}.csv`
  link.click()
  URL.revokeObjectURL(url)
}
</script>
