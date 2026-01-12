module Mutations
  class OrganizeTopic < BaseMutation
    description "トピックを整理フェーズから現状投票フェーズに移行する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      result = StartCurrentVotingService.call(topic_id: topic_id)

      {
        topic: result[:topic],
        errors: result[:errors],
      }
    end
  end
end
