import { flushPromises, mount } from '@vue/test-utils'
import { beforeEach, describe, expect, it, vi } from 'vitest'
import VoteCard from '~/components/ui/VoteCard.vue'

const voteMock = vi.fn()

vi.mock('~/composables/useVoteActions', () => ({
  useVoteActions: () => ({
    vote: voteMock,
  }),
}))

describe('VoteCard', () => {
  beforeEach(() => {
    voteMock.mockReset()
  })

  it('投票に成功すると通知を送る', async () => {
    voteMock.mockResolvedValue({
      data: {
        vote: {
          vote: { id: 'v1' },
          errors: [],
        },
      },
    })

    const wrapper = mount(VoteCard, {
      props: {
        topicId: 't1',
        participantId: 'p1',
        voteType: 'current_state',
        votes: [],
      },
    })

    expect(wrapper.text()).toContain('現状確認')

    await wrapper.findAll('button')[2].trigger('click')
    await flushPromises()

    expect(voteMock).toHaveBeenCalledWith({
      topicId: 't1',
      participantId: 'p1',
      level: 3,
      voteType: 'CURRENT_STATE',
    })
    expect(wrapper.emitted('voted')).toBeTruthy()
  })

  it('投票に失敗した場合はエラーメッセージを表示する', async () => {
    voteMock.mockResolvedValue({
      data: {
        vote: {
          vote: null,
          errors: ['投票できませんでした'],
        },
      },
    })

    const wrapper = mount(VoteCard, {
      props: {
        topicId: 't1',
        participantId: 'p1',
        voteType: 'desired_state',
        votes: [],
      },
    })

    await wrapper.findAll('button')[0].trigger('click')
    await flushPromises()

    expect(wrapper.text()).toContain('投票できませんでした')
    expect(wrapper.emitted('voted')).toBeFalsy()
  })
})
