module Mutations
  class RemoveParticipant < BaseMutation
    description "ルームから参加者を削除する"

    argument :room_id, ID, required: true, description: "ルームID"
    argument :participant_id, ID, required: true, description: "操作する参加者ID"
    argument :target_participant_id, ID, required: true, description: "削除対象の参加者ID"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(room_id:, participant_id:, target_participant_id:)
      result = RemoveParticipantService.call(
        room_id: room_id,
        participant_id: participant_id,
        target_participant_id: target_participant_id,
      )

      {
        success: result[:success],
        errors: result[:errors],
      }
    end
  end
end
