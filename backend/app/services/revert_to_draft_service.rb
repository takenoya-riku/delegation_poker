class RevertToDraftService
  include Service

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    return { success: false, topic: topic, errors: ["整理フェーズのトピックのみ対象出しに戻せます"] } unless topic.status == "organizing"

    if topic.update(status: "draft")
      { success: true, topic: topic, errors: [] }
    else
      { success: false, topic: topic, errors: topic.errors.full_messages }
    end
  end
end
