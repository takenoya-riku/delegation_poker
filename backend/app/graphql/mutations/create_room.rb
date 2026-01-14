module Mutations
  class CreateRoom < BaseMutation
    description "ルームを作成する"

    argument :name, String, required: true, description: "ルーム名"

    field :room, Types::Objects::RoomType, null: false
    field :errors, [String], null: false

    def resolve(name:)
      result = CreateRoomService.call(name: name)

      {
        room: result[:room],
        errors: result[:errors],
      }
    end
  end
end
