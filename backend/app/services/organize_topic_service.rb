class OrganizeTopicService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    return { success: false, topic: topic, errors: ["対象出しフェーズのトピックのみ整理できます"] } unless topic.status == "draft"

    if topic.start_organizing!
      { success: true, topic: topic, errors: [] }
    else
      { success: false, topic: topic, errors: topic.errors.full_messages }
    end
  end
end
