module Mutations
  class DeleteRoom < BaseMutation
    description "ルームを削除する"

    argument :room_id, ID, required: true, description: "ルームID"
    argument :participant_id, ID, required: true, description: "参加者ID"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(room_id:, participant_id:)
      result = DeleteRoomService.call(room_id: room_id, participant_id: participant_id)

      {
        success: result[:success],
        errors: result[:errors],
      }
    end
  end
end
