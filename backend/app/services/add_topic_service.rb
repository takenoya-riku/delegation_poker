class AddTopicService
  include Service

  def call(room_id:, title:, description: nil)
    room = Room.find_by(id: room_id)

    unless room
      return OpenStruct.new(
        success: false,
        topic: nil,
        errors: ['ルームが見つかりません']
      )
    end

    topic = room.topics.build(title: title, description: description, status: 'draft')

    if topic.save
      OpenStruct.new(
        success: true,
        topic: topic,
        errors: []
      )
    else
      OpenStruct.new(
        success: false,
        topic: topic,
        errors: topic.errors.full_messages
      )
    end
  end
end
