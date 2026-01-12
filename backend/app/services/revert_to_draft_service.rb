class RevertToDraftService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    unless topic.status == "organizing"
      return { success: false, topic: topic, errors: ["整理フェーズのトピックのみ対象出しに戻せます"] }
    end

    if topic.update(status: "draft")
      { success: true, topic: topic, errors: [] }
    else
      { success: false, topic: topic, errors: topic.errors.full_messages }
    end
  end
end
