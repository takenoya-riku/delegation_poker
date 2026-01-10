class OrganizeTopicService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return OpenStruct.new(success: false, topic: nil, errors: ['トピックが見つかりません']) unless topic

    unless topic.status == 'draft'
      return OpenStruct.new(success: false, topic: topic, errors: ['対象出しフェーズのトピックのみ整理できます'])
    end

    if topic.start_organizing!
      OpenStruct.new(success: true, topic: topic, errors: [])
    else
      OpenStruct.new(success: false, topic: topic, errors: topic.errors.full_messages)
    end
  end
end
