module Mutations
  class UpdateTopic < BaseMutation
    description "トピックを編集する（整理フェーズ用）"

    argument :topic_id, ID, required: true, description: "トピックID"
    argument :title, String, required: false, description: "タイトル"
    argument :description, String, required: false, description: "説明"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:, title: nil, description: nil)
      topic = Topic.find_by(id: topic_id)
      return { topic: nil, errors: ["トピックが見つかりません"] } unless topic

      return { topic: topic, errors: ["整理フェーズのトピックのみ編集できます"] } unless topic.status == "organizing"

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
