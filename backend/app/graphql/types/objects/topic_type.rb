module Types
  module Objects
    class TopicType < Types::Base::BaseObject
      field :id, ID, null: false
      field :title, String, null: false
      field :description, String, null: true
      field :status, Types::Enums::TopicStatusEnum, null: false
      field :room_id, ID, null: false
      field :votes, [Types::Objects::VoteType], null: false
      field :created_at, GraphQL::Types::ISO8601DateTime, null: false
      field :updated_at, GraphQL::Types::ISO8601DateTime, null: false

      field :average_vote_level, Float, null: true do
        description "平均投票レベル"
      end

      def average_vote_level
        object.votes.average(:level)&.round(2)
      end

      field :min_vote_level, Integer, null: true do
        description "最小投票レベル"
      end

      def min_vote_level
        object.votes.minimum(:level)
      end

      field :max_vote_level, Integer, null: true do
        description "最大投票レベル"
      end

      def max_vote_level
        object.votes.maximum(:level)
      end

      field :all_participants_voted, Boolean, null: false do
        description "すべての参加者が投票済みか"
      end

      def all_participants_voted
        object.all_participants_voted?
      end
    end
  end
end
