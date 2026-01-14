module Types
  module Objects
    class RoomType < Types::Base::BaseObject
      field :id, ID, null: false
      field :name, String, null: false
      field :code, String, null: false
      field :room_master_id, ID, null: true, description: "ルームマスターID"
      field :participants, [Types::Objects::ParticipantType], null: false
      field :topics, [Types::Objects::TopicType], null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
