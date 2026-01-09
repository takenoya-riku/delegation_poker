class VoteService
  include Service

  def call(topic_id:, participant_id:, level:)
      topic = Topic.find_by(id: topic_id)
      participant = Participant.find_by(id: participant_id)

      unless topic
        return OpenStruct.new(
          success: false,
          vote: nil,
          errors: ['トピックが見つかりません']
        )
      end

      unless participant
        return OpenStruct.new(
          success: false,
          vote: nil,
          errors: ['参加者が見つかりません']
        )
      end

      unless topic.room_id == participant.room_id
        return OpenStruct.new(
          success: false,
          vote: nil,
          errors: ['トピックと参加者が同じルームに属していません']
        )
      end

      vote = ::Vote.find_or_initialize_by(topic: topic, participant: participant)
      vote.level = level

      if vote.save
        OpenStruct.new(
          success: true,
          vote: vote,
          errors: []
        )
      else
        OpenStruct.new(
          success: false,
          vote: vote,
          errors: vote.errors.full_messages
        )
      end
    end
end
