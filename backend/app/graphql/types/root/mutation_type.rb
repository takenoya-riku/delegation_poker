module Types
  module Root
    class MutationType < Types::Base::BaseObject
      description "The mutation root of this schema"

      field :create_room, mutation: Mutations::CreateRoom
      field :join_room, mutation: Mutations::JoinRoom
      field :add_topic, mutation: Mutations::AddTopic
      field :vote, mutation: Mutations::Vote
      field :reveal_topic, mutation: Mutations::RevealTopic
    end
  end
end
