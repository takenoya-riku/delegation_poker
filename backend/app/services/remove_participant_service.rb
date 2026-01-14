class RemoveParticipantService
  include Service

  def call(room_id:, participant_id:, target_participant_id:)
    room = Room.find_by(id: room_id)
    participant = Participant.find_by(id: participant_id)
    target = Participant.find_by(id: target_participant_id)

    validation_error = validate(room: room, participant: participant, target: target)
    return validation_error if validation_error

    target.destroy!

    {
      success: true,
      errors: [],
    }
  end

  private

  def validate(room:, participant:, target:)
    presence_error = validate_presence(room: room, participant: participant, target: target)
    return presence_error if presence_error

    membership_error = validate_membership(room: room, participant: participant, target: target)
    return membership_error if membership_error

    authorization_error = validate_authorization(room: room, participant: participant, target: target)
    return authorization_error if authorization_error

    nil
  end

  def validate_presence(room:, participant:, target:)
    return error_response("ルームが見つかりません") unless room
    return error_response("参加者が見つかりません") unless participant
    return error_response("削除対象の参加者が見つかりません") unless target

    nil
  end

  def validate_membership(room:, participant:, target:)
    return error_response("参加者がこのルームに属していません") unless participant.room_id == room.id
    return error_response("削除対象の参加者がこのルームに属していません") unless target.room_id == room.id

    nil
  end

  def validate_authorization(room:, participant:, target:)
    return error_response("ルームマスターのみ削除できます") unless room.room_master_id == participant.id
    return error_response("ルームマスターは削除できません") if target.id == room.room_master_id

    nil
  end

  def error_response(message)
    {
      success: false,
      errors: [message],
    }
  end
end
