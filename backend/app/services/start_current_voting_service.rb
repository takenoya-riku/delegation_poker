class StartCurrentVotingService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    return { success: false, topic: topic, errors: ["整理フェーズのトピックのみ現状確認投票に進めます"] } unless topic.status == "organizing"

    if topic.start_current_voting!
      { success: true, topic: topic, errors: [] }
    else
      { success: false, topic: topic, errors: topic.errors.full_messages }
    end
  end
end
