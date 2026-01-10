module Mutations
  class StartOrganizing < BaseMutation
    description "トピックを対象出しフェーズから整理フェーズに移行する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      result = OrganizeTopicService.call(topic_id: topic_id)

      {
        topic: result.topic,
        errors: result.errors
      }
    end
  end
end
