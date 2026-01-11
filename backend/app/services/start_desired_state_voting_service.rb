class StartDesiredStateVotingService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    unless topic.status == "current_revealed"
      return { success: false, topic: topic, errors: ["現状確認結果が公開済みのトピックのみ、ありたい姿投票を開始できます"] }
    end

    if topic.start_desired_voting!
      { success: true, topic: topic, errors: [] }
    else
      { success: false, topic: topic, errors: topic.errors.full_messages }
    end
  end
end
