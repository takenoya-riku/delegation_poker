module Mutations
  class DeleteTopic < BaseMutation
    description "トピックを削除する（対象出し/整理フェーズ用）"

    argument :topic_id, ID, required: true, description: "トピックID"
    argument :participant_id, ID, required: true, description: "参加者ID"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(topic_id:, participant_id:)
      topic = Topic.find_by(id: topic_id)
      return not_found_response unless topic

      participant = topic.room.participants.find_by(id: participant_id)
      return participant_not_found_response unless participant

      return forbidden_response(topic, participant) unless deletable?(topic, participant)

      destroy_topic(topic)
    end

    private

    def not_found_response
      { success: false, errors: ["トピックが見つかりません"] }
    end

    def participant_not_found_response
      { success: false, errors: ["参加者が見つかりません"] }
    end

    def deletable?(topic, participant)
      topic.status == "organizing" || (topic.status == "draft" && topic.participant_id == participant.id)
    end

    def forbidden_response(topic, participant)
      if topic.status == "draft" && topic.participant_id != participant.id
        return { success: false, errors: ["自分の対象出しトピックのみ削除できます"] }
      end

      { success: false, errors: ["対象出し/整理フェーズのトピックのみ削除できます"] }
    end

    def destroy_topic(topic)
      if topic.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: topic.errors.full_messages }
      end
    end
  end
end
