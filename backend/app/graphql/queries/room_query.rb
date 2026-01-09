module Queries
  class RoomQuery < BaseQuery
    description "ルームコードでルーム情報を取得する"

    type Types::Objects::RoomType, null: true

    argument :code, String, required: true, description: "ルームコード"

    def resolve(code:)
      Room.find_by(code: code.upcase)
    end
  end
end
