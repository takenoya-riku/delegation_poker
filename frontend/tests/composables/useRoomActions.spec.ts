import { describe, expect, it, vi } from 'vitest'
import { useRoomActions } from '~/composables/useRoomActions'

const useMutationMock = vi.fn()

vi.mock('@urql/vue', () => ({
  useMutation: (document: unknown) => useMutationMock(document),
}))

vi.mock('~/graphql/generated/types', () => ({
  CreateRoomDocument: 'CreateRoomDocument',
  JoinRoomDocument: 'JoinRoomDocument',
  DeleteRoomDocument: 'DeleteRoomDocument',
}))

describe('useRoomActions', () => {
  it('各アクションが対応するMutationを呼び出す', () => {
    const documents: unknown[] = []
    const executeMutationMocks: Array<ReturnType<typeof vi.fn>> = []

    useMutationMock.mockImplementation((document: unknown) => {
      documents.push(document)
      const executeMutation = vi.fn()
      executeMutationMocks.push(executeMutation)
      return { executeMutation }
    })

    const { createRoom, joinRoom, deleteRoom } = useRoomActions()

    createRoom({ name: '新しいルーム' })
    joinRoom({ code: 'AB12CD', name: '山田太郎' })
    deleteRoom({ roomId: 'room-1', participantId: 'p1' })

    expect(documents).toEqual([
      'CreateRoomDocument',
      'JoinRoomDocument',
      'DeleteRoomDocument',
    ])
    expect(executeMutationMocks[0]).toHaveBeenCalledWith({ name: '新しいルーム' })
    expect(executeMutationMocks[1]).toHaveBeenCalledWith({ code: 'AB12CD', name: '山田太郎' })
    expect(executeMutationMocks[2]).toHaveBeenCalledWith({ roomId: 'room-1', participantId: 'p1' })
  })
})
