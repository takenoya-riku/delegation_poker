module Types
  module Root
    class MutationType < Types::Base::BaseObject
      description "The mutation root of this schema"

      field :create_room, mutation: Mutations::CreateRoom
      field :join_room, mutation: Mutations::JoinRoom
      field :add_topic, mutation: Mutations::AddTopic
      field :update_topic, mutation: Mutations::UpdateTopic
      field :delete_topic, mutation: Mutations::DeleteTopic
      field :merge_topics, mutation: Mutations::MergeTopics
      field :organize_topic, mutation: Mutations::OrganizeTopic
      field :start_organizing, mutation: Mutations::StartOrganizing
      field :vote, mutation: Mutations::Vote
      field :reveal_current_state, mutation: Mutations::RevealCurrentState
      field :start_desired_state_voting, mutation: Mutations::StartDesiredStateVoting
      field :reveal_desired_state, mutation: Mutations::RevealDesiredState
      field :reveal_topic, mutation: Mutations::RevealTopic
    end
  end
end
