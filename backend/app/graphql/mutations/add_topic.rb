module Mutations
  class AddTopic < BaseMutation
    description "トピックを追加する"

    argument :room_id, ID, required: true, description: "ルームID"
    argument :participant_id, ID, required: true, description: "参加者ID"
    argument :title, String, required: true, description: "トピックタイトル"
    argument :description, String, required: false, description: "説明"

    field :topic, Types::Objects::TopicType, null: true
    field :errors, [String], null: false

    def resolve(room_id:, participant_id:, title:, description: nil)
      # TODO: 認証認可の実装
      # authorize! :add_topic, Room.find_by(id: room_id)

      result = AddTopicService.call(
        room_id: room_id,
        participant_id: participant_id,
        title: title,
        description: description,
      )

      {
        topic: result[:topic],
        errors: result[:errors],
      }
    end
  end
end
