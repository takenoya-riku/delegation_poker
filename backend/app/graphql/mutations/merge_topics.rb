module Mutations
  class MergeTopics < BaseMutation
    description "トピックを統合する（整理フェーズ用）"

    argument :source_topic_id, ID, required: true, description: "統合元のトピックID"
    argument :target_topic_id, ID, required: true, description: "統合先のトピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(source_topic_id:, target_topic_id:)
      result = MergeTopicsService.call(
        source_topic_id: source_topic_id,
        target_topic_id: target_topic_id
      )

      {
        topic: result.topic,
        errors: result.errors
      }
    end
  end
end
