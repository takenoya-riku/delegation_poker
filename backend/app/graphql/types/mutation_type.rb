module Types
  class MutationType < BaseObject
    description "The mutation root of this schema"

    # Add your mutation fields here
    # Example mutation:
    # field :create_user, mutation: Mutations::CreateUser
    
    # Temporary field to satisfy GraphQL schema requirements
    # Remove this when you add your first real mutation
    field :test_mutation, String, null: false,
      description: "A temporary test mutation"
    def test_mutation
      "Test mutation response"
    end
  end
end
