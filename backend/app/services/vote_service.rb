class VoteService
  include Service

  def call(topic_id:, participant_id:, level:, vote_type:)
    topic = Topic.find_by(id: topic_id)
    participant = Participant.find_by(id: participant_id)

    unless topic
      return {
        success: false,
        vote: nil,
        errors: ["トピックが見つかりません"],
      }
    end

    unless participant
      return {
        success: false,
        vote: nil,
        errors: ["参加者が見つかりません"],
      }
    end

    unless topic.room_id == participant.room_id
      return {
        success: false,
        vote: nil,
        errors: ["トピックと参加者が同じルームに属していません"],
      }
    end

    unless can_vote?(topic: topic, vote_type: vote_type)
      return {
        success: false,
        vote: nil,
        errors: ["この投票はすでに締め切られています"],
      }
    end

    vote = ::Vote.find_or_initialize_by(
      topic: topic,
      participant: participant,
      vote_type: vote_type,
    )
    vote.level = level

    if vote.save
      {
        success: true,
        vote: vote,
        errors: [],
      }
    else
      {
        success: false,
        vote: vote,
        errors: vote.errors.full_messages,
      }
    end
  end

  private

  def can_vote?(topic:, vote_type:)
    case vote_type
    when "current_state"
      topic.status == "current_voting"
    when "desired_state"
      topic.status == "desired_voting"
    else
      false
    end
  end
end
