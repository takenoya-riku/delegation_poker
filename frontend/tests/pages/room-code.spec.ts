import { nextTick, ref } from 'vue'
import { mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import RoomPage from '~/pages/room/[code].vue'

const executeQueryMock = vi.fn()
const executeMutationMock = vi.fn()

const queryState = {
  data: ref<null | {
    room: {
      id: string
      code: string
      name: string
      roomMasterId?: string | null
      participants: Array<{ id: string; name: string }>
      topics: Array<{ id: string; status: string }>
    }
  }>(null),
  fetching: ref(false),
  error: ref(null),
  executeQuery: executeQueryMock,
}

vi.mock('@urql/vue', () => ({
  useQuery: vi.fn(() => queryState),
  useMutation: vi.fn(() => ({ executeMutation: executeMutationMock })),
}))

const stubs = {
  NuxtLink: {
    props: ['to'],
    template: '<a :href="to"><slot /></a>',
  },
  ParticipantList: {
    template: '<div data-test="participant-list" />',
  },
  TopicDraftList: {
    template: '<div data-test="topic-draft-list" />',
  },
  TopicOrganizeView: {
    template: '<div data-test="topic-organize-view" />',
  },
  VotingBoard: {
    template: '<div data-test="voting-board" />',
  },
}

describe('ルームページ', () => {
  beforeEach(() => {
    vi.stubGlobal('useRoute', () => ({ params: { code: 'ab12cd' } }))
    localStorage.clear()
    sessionStorage.clear()
    queryState.data.value = null
    queryState.fetching.value = false
    queryState.error.value = null
    executeQueryMock.mockReset()
    executeMutationMock.mockReset()
  })

  it('読み込み中の表示を行う', async () => {
    queryState.fetching.value = true

    const wrapper = mount(RoomPage, {
      global: { stubs },
    })

    await nextTick()

    expect(wrapper.text()).toContain('読み込み中...')
    wrapper.unmount()
  })

  it('対象出しフェーズの内容を表示する', async () => {
    localStorage.setItem('participant_AB12CD', 'p1')
    queryState.data.value = {
      room: {
        id: 'room-1',
        code: 'ab12cd',
        name: 'テストルーム',
        roomMasterId: 'p1',
        participants: [{ id: 'p1', name: '参加者' }],
        topics: [{ id: 't1', status: 'DRAFT' }],
      },
    }

    const wrapper = mount(RoomPage, {
      global: { stubs },
    })

    await nextTick()

    expect(wrapper.text()).toContain('テストルーム')
    expect(wrapper.text()).toContain('ルームコード: ab12cd')
    expect(wrapper.find('[data-test="topic-draft-list"]').exists()).toBe(true)
    expect(localStorage.getItem('saved_rooms')).toContain('テストルーム')
    wrapper.unmount()
  })

  it('参加していないルームの場合はエラーメッセージを表示する', async () => {
    localStorage.setItem('participant_AB12CD', 'p-other')
    queryState.data.value = {
      room: {
        id: 'room-1',
        code: 'ab12cd',
        name: 'テストルーム',
        roomMasterId: 'p1',
        participants: [{ id: 'p1', name: '参加者' }],
        topics: [],
      },
    }

    const wrapper = mount(RoomPage, {
      global: { stubs },
    })

    await nextTick()

    expect(wrapper.text()).toContain('ルームは解散しました')
    wrapper.unmount()
  })
})
