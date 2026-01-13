module Mutations
  class DeleteTopic < BaseMutation
    description "トピックを削除する（対象出し/整理フェーズ用）"

    argument :topic_id, ID, required: true, description: "トピックID"
    argument :participant_id, ID, required: true, description: "参加者ID"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(topic_id:, participant_id:)
      topic = Topic.find_by(id: topic_id)
      return { success: false, errors: ["トピックが見つかりません"] } unless topic

      participant = topic.room.participants.find_by(id: participant_id)
      return { success: false, errors: ["参加者が見つかりません"] } unless participant

      unless topic.status == "organizing" || (topic.status == "draft" && topic.participant_id == participant.id)
        return { success: false, errors: ["自分の対象出しトピックのみ削除できます"] } if topic.status == "draft"

        return { success: false, errors: ["対象出し/整理フェーズのトピックのみ削除できます"] }
      end

      if topic.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: topic.errors.full_messages }
      end
    end
  end
end
