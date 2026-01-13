module Mutations
  class RevertToOrganizing < BaseMutation
    description "トピックを投票フェーズから整理フェーズに戻す"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      result = RevertToOrganizingService.call(topic_id: topic_id)

      {
        topic: result[:topic],
        errors: result[:errors],
      }
    end
  end
end
