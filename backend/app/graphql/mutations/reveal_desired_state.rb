module Mutations
  class RevealDesiredState < BaseMutation
    description "ありたい姿の投票結果を公開する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      topic = Topic.find_by(id: topic_id)
      return { topic: nil, errors: ["トピックが見つかりません"] } unless topic

      return { topic: topic, errors: ["ありたい姿投票中のトピックのみ公開できます"] } unless topic.status == "desired_voting"

      if topic.reveal_desired_state!
        { topic: topic, errors: [] }
      else
        { topic: topic, errors: topic.errors.full_messages }
      end
    end
  end
end
