class AddTopicService
  include Service

  def call(room_id:, title:, description: nil, participant_id:)
    room = Room.find_by(id: room_id)

    unless room
      return {
        success: false,
        topic: nil,
        errors: ["ルームが見つかりません"],
      }
    end

    participant = room.participants.find_by(id: participant_id)

    unless participant
      return {
        success: false,
        topic: nil,
        errors: ["参加者が見つかりません"],
      }
    end

    topic = room.topics.build(
      title: title,
      description: description,
      status: "draft",
      participant_id: participant.id,
    )

    if topic.save
      {
        success: true,
        topic: topic,
        errors: [],
      }
    else
      {
        success: false,
        topic: topic,
        errors: topic.errors.full_messages,
      }
    end
  end
end
