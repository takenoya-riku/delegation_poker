import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import TopicOrganizeView from '~/components/features/TopicOrganizeView.vue'

const updateTopicMock = vi.fn()
const deleteTopicMock = vi.fn()
const organizeTopicMock = vi.fn()
const revertToDraftMock = vi.fn()

vi.mock('~/composables/useTopicActions', () => ({
  useTopicActions: () => ({
    updateTopic: updateTopicMock,
    deleteTopic: deleteTopicMock,
    organizeTopic: organizeTopicMock,
    revertToDraft: revertToDraftMock,
  }),
}))

const baseProps = {
  topics: [],
  participants: [
    { id: 'p1', name: '山田太郎' },
    { id: 'p2', name: '佐藤花子' },
  ],
  isRoomMaster: false,
  currentParticipantId: 'p1',
}

describe('TopicOrganizeView', () => {
  beforeEach(() => {
    updateTopicMock.mockReset()
    deleteTopicMock.mockReset()
    organizeTopicMock.mockReset()
    revertToDraftMock.mockReset()
  })

  it('整理対象がない場合は空状態を表示する', () => {
    const wrapper = mount(TopicOrganizeView, { props: baseProps })

    expect(wrapper.text()).toContain('整理する対象がありません')
  })

  it('投票フェーズへの移行で整理済みトピックを処理する', async () => {
    organizeTopicMock.mockResolvedValue({
      data: {
        organizeTopic: {
          topic: { id: 't1' },
          errors: [],
        },
      },
    })

    const wrapper = mount(TopicOrganizeView, {
      props: {
        ...baseProps,
        isRoomMaster: true,
        topics: [
          { id: 't1', title: 'トピック1', description: null, status: 'ORGANIZING', participantId: 'p1' },
          { id: 't2', title: 'トピック2', description: null, status: 'ORGANIZING', participantId: 'p2' },
        ],
      },
    })

    const startButton = wrapper.findAll('button').find(button => button.text().includes('投票に進む'))
    if (!startButton) throw new Error('投票に進むボタンが見つかりません')
    await startButton.trigger('click')
    await flushPromises()

    expect(organizeTopicMock).toHaveBeenCalledTimes(2)
    expect(organizeTopicMock).toHaveBeenCalledWith({ topicId: 't1' })
    expect(organizeTopicMock).toHaveBeenCalledWith({ topicId: 't2' })
    expect(wrapper.emitted('refresh')).toBeTruthy()
  })
})
