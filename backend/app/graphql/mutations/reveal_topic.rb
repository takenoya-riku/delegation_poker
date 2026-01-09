module Mutations
  class RevealTopic < BaseMutation
    description "トピックの投票結果を公開する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      # TODO: 認証認可の実装
      # authorize! :reveal, Topic.find_by(id: topic_id)

      result = RevealTopicService.call(topic_id: topic_id)

      {
        topic: result.topic,
        errors: result.errors
      }
    end
  end
end
