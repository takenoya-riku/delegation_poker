module Mutations
  class JoinRoom < BaseMutation
    description "ルームに参加する"

    argument :code, String, required: true, description: "ルームコード"
    argument :name, String, required: true, description: "参加者名"

    field :participant, Types::Objects::ParticipantType, null: true
    field :room, Types::Objects::RoomType, null: true
    field :errors, [String], null: false

    def resolve(code:, name:)
      result = JoinRoomService.call(code: code, name: name)

      {
        participant: result[:participant],
        room: result[:room],
        errors: result[:errors],
      }
    end
  end
end
