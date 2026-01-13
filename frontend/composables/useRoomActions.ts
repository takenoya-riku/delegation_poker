import { useMutation } from '@urql/vue'
import { CreateRoomDocument, DeleteRoomDocument, JoinRoomDocument } from '~/graphql/generated/types'

export const useRoomActions = () => {
  const createRoomMutation = useMutation(CreateRoomDocument)
  const joinRoomMutation = useMutation(JoinRoomDocument)
  const deleteRoomMutation = useMutation(DeleteRoomDocument)

  const createRoom = (variables: { name: string }) => {
    return createRoomMutation.executeMutation(variables)
  }

  const joinRoom = (variables: { code: string; name: string }) => {
    return joinRoomMutation.executeMutation(variables)
  }

  const deleteRoom = (variables: { roomId: string; participantId: string }) => {
    return deleteRoomMutation.executeMutation(variables)
  }

  return {
    createRoom,
    joinRoom,
    deleteRoom,
  }
}
