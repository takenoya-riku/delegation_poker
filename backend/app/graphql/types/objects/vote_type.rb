module Types
  module Objects
    class VoteType < Types::Base::BaseObject
      field :id, ID, null: false
      field :level, Integer, null: false
      field :vote_type, Types::Enums::VoteTypeEnum, null: false
      field :topic_id, ID, null: false
      field :participant_id, ID, null: false
      field :participant, Types::Objects::ParticipantType, null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false
    end
  end
end
