import { describe, expect, it, vi } from 'vitest'
import { useVoteActions } from '~/composables/useVoteActions'

const useMutationMock = vi.fn()
vi.mock('@urql/vue', () => ({
  useMutation: (document: unknown) => useMutationMock(document),
}))

vi.mock('graphql-tag', () => ({
  default: vi.fn(() => 'RevertToOrganizingDocument'),
}))

vi.mock('~/graphql/generated/types', () => ({
  VoteDocument: 'VoteDocument',
  RevealCurrentStateDocument: 'RevealCurrentStateDocument',
  StartDesiredStateVotingDocument: 'StartDesiredStateVotingDocument',
  RevealDesiredStateDocument: 'RevealDesiredStateDocument',
}))

describe('useVoteActions', () => {
  it('各アクションが対応するMutationを呼び出す', () => {
    const documents: unknown[] = []
    const executeMutationMocks: Array<ReturnType<typeof vi.fn>> = []

    useMutationMock.mockImplementation((document: unknown) => {
      documents.push(document)
      const executeMutation = vi.fn()
      executeMutationMocks.push(executeMutation)
      return { executeMutation }
    })

    const { vote, revealCurrentState, startDesiredStateVoting, revealDesiredState, revertToOrganizing } = useVoteActions()

    vote({ topicId: 't1', participantId: 'p1', level: 3, voteType: 'CURRENT_STATE' })
    revealCurrentState({ topicId: 't1' })
    startDesiredStateVoting({ topicId: 't1' })
    revealDesiredState({ topicId: 't1' })
    revertToOrganizing({ topicId: 't1' })

    expect(documents).toEqual([
      'VoteDocument',
      'RevealCurrentStateDocument',
      'StartDesiredStateVotingDocument',
      'RevealDesiredStateDocument',
      'RevertToOrganizingDocument',
    ])
    expect(executeMutationMocks[0]).toHaveBeenCalledWith({
      topicId: 't1',
      participantId: 'p1',
      level: 3,
      voteType: 'CURRENT_STATE',
    })
    expect(executeMutationMocks[1]).toHaveBeenCalledWith({ topicId: 't1' })
    expect(executeMutationMocks[2]).toHaveBeenCalledWith({ topicId: 't1' })
    expect(executeMutationMocks[3]).toHaveBeenCalledWith({ topicId: 't1' })
    expect(executeMutationMocks[4]).toHaveBeenCalledWith({ topicId: 't1' })
  })
})
