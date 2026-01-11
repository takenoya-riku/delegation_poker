class JoinRoomService
  include Service

  def call(code:, name:)
    room = Room.find_by(code: code.upcase)

    unless room
      return {
        success: false,
        participant: nil,
        room: nil,
        errors: ["ルームが見つかりません"],
      }
    end

    participant = room.participants.build(name: name)

    if participant.save
      {
        success: true,
        participant: participant,
        room: room,
        errors: [],
      }
    else
      {
        success: false,
        participant: participant,
        room: room,
        errors: participant.errors.full_messages,
      }
    end
  end
end
