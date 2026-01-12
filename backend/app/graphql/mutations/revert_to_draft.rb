module Mutations
  class RevertToDraft < BaseMutation
    description "トピックを整理フェーズから対象出しフェーズに戻す"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      result = RevertToDraftService.call(topic_id: topic_id)

      {
        topic: result[:topic],
        errors: result[:errors],
      }
    end
  end
end
