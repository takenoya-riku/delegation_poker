class CreateRoomService
  include Service

  def call(name:)
    room = Room.new(name: name)

    if room.save
      { success: true, room: room, errors: [] }
    else
      { success: false, room: room, errors: room.errors.full_messages }
    end
  end
end
