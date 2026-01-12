class DeleteRoomService
  include Service

  def call(room_id:, participant_id:)
    room = Room.find_by(id: room_id)
    participant = Participant.find_by(id: participant_id)

    validation_error = validate(room: room, participant: participant)
    return validation_error if validation_error

    room.update!(room_master_id: nil)
    room.destroy!

    {
      success: true,
      errors: [],
    }
  end

  private

  def validate(room:, participant:)
    return error_response("ルームが見つかりません") unless room
    return error_response("参加者が見つかりません") unless participant
    return error_response("参加者がこのルームに属していません") unless participant.room_id == room.id
    return error_response("ルームマスターのみ削除できます") unless room.room_master_id == participant.id

    nil
  end

  def error_response(message)
    {
      success: false,
      errors: [message],
    }
  end
end
