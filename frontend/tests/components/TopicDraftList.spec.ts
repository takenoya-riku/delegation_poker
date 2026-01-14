import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import TopicDraftList from '~/components/features/TopicDraftList.vue'

const addTopicMock = vi.fn()
const startOrganizingMock = vi.fn()
const updateTopicMock = vi.fn()
const deleteTopicMock = vi.fn()

vi.mock('~/composables/useTopicActions', () => ({
  useTopicActions: () => ({
    addTopic: addTopicMock,
    startOrganizing: startOrganizingMock,
    updateTopic: updateTopicMock,
    deleteTopic: deleteTopicMock,
  }),
}))

const baseProps = {
  topics: [],
  participants: [
    { id: 'p1', name: '山田太郎' },
    { id: 'p2', name: '佐藤花子' },
  ],
  roomId: 'room-1',
  isRoomMaster: false,
  currentParticipantId: 'p1',
}

describe('TopicDraftList', () => {
  beforeEach(() => {
    addTopicMock.mockReset()
    startOrganizingMock.mockReset()
    updateTopicMock.mockReset()
    deleteTopicMock.mockReset()
  })

  it('トピックがない場合は空状態を表示する', () => {
    const wrapper = mount(TopicDraftList, { props: baseProps })

    expect(wrapper.text()).toContain('まだ対象が追加されていません')
  })

  it('対象追加に成功するとリフレッシュを通知する', async () => {
    addTopicMock.mockResolvedValue({
      data: {
        addTopic: {
          topic: { id: 't1' },
          errors: [],
        },
      },
    })

    const wrapper = mount(TopicDraftList, { props: baseProps })
    await wrapper.find('input[placeholder="トピックタイトル"]').setValue('新しいトピック')
    await wrapper.find('textarea[placeholder="説明（オプション）"]').setValue('説明文')
    await wrapper.find('form').trigger('submit')
    await flushPromises()

    expect(addTopicMock).toHaveBeenCalledWith({
      roomId: 'room-1',
      participantId: 'p1',
      title: '新しいトピック',
      description: '説明文',
    })
    expect(wrapper.emitted('refresh')).toBeTruthy()
  })

  it('自分のトピックだけ編集操作を表示する', () => {
    const wrapper = mount(TopicDraftList, {
      props: {
        ...baseProps,
        topics: [
          { id: 't1', title: '自分のトピック', description: null, status: 'DRAFT', participantId: 'p1' },
          { id: 't2', title: '他人のトピック', description: null, status: 'DRAFT', participantId: 'p2' },
        ],
      },
    })

    const editButtons = wrapper.findAll('button').filter(button => button.text() === '編集')
    expect(editButtons).toHaveLength(1)
    expect(wrapper.text()).toContain('整理フェーズへの移行はルームマスターのみ可能です')
  })
})
