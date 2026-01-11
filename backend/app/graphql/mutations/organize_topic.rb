module Mutations
  class OrganizeTopic < BaseMutation
    description "トピックを整理フェーズから現状投票フェーズに移行する"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(topic_id:)
      # まず整理フェーズに移行
      organize_result = OrganizeTopicService.call(topic_id: topic_id)
      return { topic: organize_result[:topic], errors: organize_result[:errors] } unless organize_result[:success]

      # 整理フェーズから現状投票フェーズに移行
      topic = organize_result[:topic]
      if topic.start_current_voting!
        { topic: topic, errors: [] }
      else
        { topic: topic, errors: topic.errors.full_messages }
      end
    end
  end
end
