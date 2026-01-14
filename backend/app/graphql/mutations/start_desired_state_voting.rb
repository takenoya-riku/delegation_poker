module Mutations
  class StartDesiredStateVoting < BaseMutation
    description "理想投票フェーズを開始する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      result = StartDesiredStateVotingService.call(topic_id: topic_id)

      {
        topic: result[:topic],
        errors: result[:errors],
      }
    end
  end
end
