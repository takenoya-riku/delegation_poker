module Mutations
  class RevealCurrentState < BaseMutation
    description "現状確認の投票結果を公開する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      topic = Topic.find_by(id: topic_id)
      return { topic: nil, errors: ['トピックが見つかりません'] } unless topic

      unless topic.status == 'current_voting'
        return { topic: topic, errors: ['現状確認投票中のトピックのみ公開できます'] }
      end

      if topic.reveal_current_state!
        { topic: topic, errors: [] }
      else
        { topic: topic, errors: topic.errors.full_messages }
      end
    end
  end
end
