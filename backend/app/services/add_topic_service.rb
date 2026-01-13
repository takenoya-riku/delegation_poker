class AddTopicService
  include Service

  def call(room_id:, title:, participant_id:, description: nil)
    room = Room.find_by(id: room_id)
    return room_not_found_response unless room

    participant = room.participants.find_by(id: participant_id)
    return participant_not_found_response unless participant

    topic = build_topic(room, participant, title: title, description: description)
    save_topic(topic)
  end

  private

  def room_not_found_response
    {
      success: false,
      topic: nil,
      errors: ["ルームが見つかりません"],
    }
  end

  def participant_not_found_response
    {
      success: false,
      topic: nil,
      errors: ["参加者が見つかりません"],
    }
  end

  def build_topic(room, participant, title:, description:)
    room.topics.build(
      title: title,
      description: description,
      status: "draft",
      participant_id: participant.id,
    )
  end

  def save_topic(topic)
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
