module Types
  module Root
    class QueryType < Types::Base::BaseObject
      description "The query root of this schema"

      field :room, resolver: Queries::RoomQuery
    end
  end
end
