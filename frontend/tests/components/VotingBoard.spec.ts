import { mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import VotingBoard from '~/components/features/VotingBoard.vue'

const revealCurrentStateMock = vi.fn()
const startDesiredStateVotingMock = vi.fn()
const revealDesiredStateMock = vi.fn()
const revertToOrganizingMock = vi.fn()

vi.mock('~/composables/useVoteActions', () => ({
  useVoteActions: () => ({
    revealCurrentState: revealCurrentStateMock,
    startDesiredStateVoting: startDesiredStateVotingMock,
    revealDesiredState: revealDesiredStateMock,
    revertToOrganizing: revertToOrganizingMock,
  }),
}))

const baseProps = {
  topics: [
    {
      id: 't1',
      title: 'トピックA',
      description: null,
      status: 'current_voting',
      participantId: 'p1',
      votes: [],
    },
  ],
  participants: [
    { id: 'p1', name: '山田太郎' },
    { id: 'p2', name: '佐藤花子' },
  ],
  participantId: 'p1',
  totalParticipants: 2,
  isRoomMaster: true,
}

describe('VotingBoard', () => {
  beforeEach(() => {
    revealCurrentStateMock.mockReset()
    startDesiredStateVotingMock.mockReset()
    revealDesiredStateMock.mockReset()
    revertToOrganizingMock.mockReset()
  })

  it('主要なラベルと操作ボタンを表示する', () => {
    const wrapper = mount(VotingBoard, {
      props: baseProps,
      global: {
        stubs: {
          VoteCard: {
            template: '<div data-test="vote-card" />',
          },
        },
      },
    })

    expect(wrapper.text()).toContain('現状確認投票中')
    expect(wrapper.text()).toContain('現状投票')
    expect(wrapper.text()).toContain('↩️ 整理フェーズに戻す')
  })

  it('投票ボタンでモーダルを開く', async () => {
    const wrapper = mount(VotingBoard, {
      props: { ...baseProps, isRoomMaster: false },
      global: {
        stubs: {
          VoteCard: {
            template: '<div data-test="vote-card" />',
          },
        },
      },
    })

    const voteButton = wrapper.findAll('button').find(button => button.text().includes('現状投票'))
    if (!voteButton) throw new Error('現状投票ボタンが見つかりません')
    await voteButton.trigger('click')

    expect(wrapper.find('.modal.modal-open').exists()).toBe(true)
    expect(wrapper.find('.modal-box h3').text()).toContain('トピックA')
  })
})
