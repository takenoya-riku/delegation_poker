class RevealTopicService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)

    unless topic
      return {
        success: false,
        topic: nil,
        errors: ["トピックが見つかりません"],
      }
    end

    if %w[current_revealed desired_revealed completed].include?(topic.status)
      return {
        success: false,
        topic: topic,
        errors: ["既に結果が公開されています"],
      }
    end

    topic.reveal!
    {
      success: true,
      topic: topic.reload,
      errors: [],
    }
  rescue ActiveRecord::RecordInvalid
    {
      success: false,
      topic: topic,
      errors: topic.errors.full_messages,
    }
  end
end
