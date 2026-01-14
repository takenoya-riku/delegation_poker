import { describe, expect, it, vi } from 'vitest'
import { useTopicActions } from '~/composables/useTopicActions'

const useMutationMock = vi.fn()
const gqlMock = vi.fn(() => 'RevertToDraftDocument')

vi.mock('@urql/vue', () => ({
  useMutation: (document: unknown) => useMutationMock(document),
}))

vi.mock('graphql-tag', () => ({
  default: gqlMock,
}))

vi.mock('~/graphql/generated/types', () => ({
  AddTopicDocument: 'AddTopicDocument',
  UpdateTopicDocument: 'UpdateTopicDocument',
  DeleteTopicDocument: 'DeleteTopicDocument',
  StartOrganizingDocument: 'StartOrganizingDocument',
  OrganizeTopicDocument: 'OrganizeTopicDocument',
}))

describe('useTopicActions', () => {
  it('各アクションが対応するMutationを呼び出す', () => {
    const documents: unknown[] = []
    const executeMutationMocks: Array<ReturnType<typeof vi.fn>> = []

    useMutationMock.mockImplementation((document: unknown) => {
      documents.push(document)
      const executeMutation = vi.fn()
      executeMutationMocks.push(executeMutation)
      return { executeMutation }
    })

    const { addTopic, updateTopic, deleteTopic, startOrganizing, organizeTopic, revertToDraft } = useTopicActions()

    addTopic({ roomId: 'room-1', participantId: 'p1', title: '題材', description: '説明' })
    updateTopic({ topicId: 't1', participantId: 'p1', title: '更新', description: null })
    deleteTopic({ topicId: 't1', participantId: 'p1' })
    startOrganizing({ topicId: 't1' })
    organizeTopic({ topicId: 't2' })
    revertToDraft({ topicId: 't3' })

    expect(documents).toEqual([
      'AddTopicDocument',
      'UpdateTopicDocument',
      'DeleteTopicDocument',
      'StartOrganizingDocument',
      'OrganizeTopicDocument',
      'RevertToDraftDocument',
    ])
    expect(executeMutationMocks[0]).toHaveBeenCalledWith({
      roomId: 'room-1',
      participantId: 'p1',
      title: '題材',
      description: '説明',
    })
    expect(executeMutationMocks[1]).toHaveBeenCalledWith({
      topicId: 't1',
      participantId: 'p1',
      title: '更新',
      description: null,
    })
    expect(executeMutationMocks[2]).toHaveBeenCalledWith({
      topicId: 't1',
      participantId: 'p1',
    })
    expect(executeMutationMocks[3]).toHaveBeenCalledWith({ topicId: 't1' })
    expect(executeMutationMocks[4]).toHaveBeenCalledWith({ topicId: 't2' })
    expect(executeMutationMocks[5]).toHaveBeenCalledWith({ topicId: 't3' })
  })
})
