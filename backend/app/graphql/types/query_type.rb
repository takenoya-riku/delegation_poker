module Types
  class QueryType < BaseObject
    description "The query root of this schema"

    # Add your root fields here
    # field :node, field: GraphQL::Relay::Node.field

    # Example field
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end
  end
end
