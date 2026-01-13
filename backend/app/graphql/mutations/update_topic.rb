module Mutations
  class UpdateTopic < BaseMutation
    description "トピックを編集する（対象出し/整理フェーズ用）"

    argument :topic_id, ID, required: true, description: "トピックID"
    argument :participant_id, ID, required: true, description: "参加者ID"
    argument :title, String, required: false, description: "タイトル"
    argument :description, String, required: false, description: "説明"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:, participant_id:, title: nil, description: nil)
      topic = Topic.find_by(id: topic_id)
      return not_found_response unless topic

      participant = topic.room.participants.find_by(id: participant_id)
      return participant_not_found_response(topic) unless participant

      return forbidden_response(topic, participant) unless updatable?(topic, participant)

      update_topic(topic, title: title, description: description)
    end

    private

    def not_found_response
      { topic: nil, errors: ["トピックが見つかりません"] }
    end

    def participant_not_found_response(topic)
      { topic: topic, errors: ["参加者が見つかりません"] }
    end

    def updatable?(topic, participant)
      topic.status == "organizing" || (topic.status == "draft" && topic.participant_id == participant.id)
    end

    def forbidden_response(topic, participant)
      if topic.status == "draft" && topic.participant_id != participant.id
        return { topic: topic, errors: ["自分の対象出しトピックのみ編集できます"] }
      end

      { topic: topic, errors: ["対象出し/整理フェーズのトピックのみ編集できます"] }
    end

    def update_topic(topic, title:, description:)
      attributes = {}
      attributes[:title] = title if title.present?
      attributes[:description] = description if description.present?

      if topic.update(attributes)
        { topic: topic, errors: [] }
      else
        { topic: topic, errors: topic.errors.full_messages }
      end
    end
  end
end
