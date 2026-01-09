class RevealTopicService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)

    unless topic
      return OpenStruct.new(
        success: false,
        topic: nil,
        errors: ['トピックが見つかりません']
      )
    end

    if topic.status == 'revealed'
      return OpenStruct.new(
        success: false,
        topic: topic,
        errors: ['既に結果が公開されています']
      )
    end

    topic.reveal!
    OpenStruct.new(
      success: true,
      topic: topic.reload,
      errors: []
    )
  rescue ActiveRecord::RecordInvalid => e
    OpenStruct.new(
      success: false,
      topic: topic,
      errors: topic.errors.full_messages
    )
  end
end
