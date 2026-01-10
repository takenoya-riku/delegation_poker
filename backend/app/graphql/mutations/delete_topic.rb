module Mutations
  class DeleteTopic < BaseMutation
    description "トピックを削除する（整理フェーズ用）"

    argument :topic_id, ID, required: true, description: "トピックID"

    field :success, Boolean, null: false
    field :errors, [String], null: false

    def resolve(topic_id:)
      topic = Topic.find_by(id: topic_id)
      return { success: false, errors: ['トピックが見つかりません'] } unless topic

      unless topic.status == 'organizing'
        return { success: false, errors: ['整理フェーズのトピックのみ削除できます'] }
      end

      if topic.destroy
        { success: true, errors: [] }
      else
        { success: false, errors: topic.errors.full_messages }
      end
    end
  end
end
