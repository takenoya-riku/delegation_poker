class CreateRoomService
  include Service

  def call(name:)
    room = Room.new(name: name)

    if room.save
      OpenStruct.new(success: true, room: room, errors: [])
    else
      OpenStruct.new(success: false, room: room, errors: room.errors.full_messages)
    end
  end
end
