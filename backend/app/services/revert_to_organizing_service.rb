class RevertToOrganizingService
  include Service

  VOTING_STATUSES = %w[current_voting current_revealed desired_voting desired_revealed completed].freeze

  def call(topic_id:)
    topic = Topic.find_by(id: topic_id)
    return { success: false, topic: nil, errors: ["トピックが見つかりません"] } unless topic

    unless VOTING_STATUSES.include?(topic.status)
      return { success: false, topic: topic, errors: ["投票フェーズのトピックのみ整理フェーズに戻せます"] }
    end

    Topic.transaction do
      topic.votes.destroy_all
      topic.update!(status: "organizing")
    end

    { success: true, topic: topic, errors: [] }
  rescue ActiveRecord::RecordInvalid => e
    { success: false, topic: topic, errors: e.record.errors.full_messages }
  end
end
