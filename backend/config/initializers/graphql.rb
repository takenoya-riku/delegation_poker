# GraphQL configuration
# See https://graphql-ruby.org/ for more information

# Configure GraphQL schema
GraphQL::Schema::Printer.print(DelegationPokerSchema) if defined?(DelegationPokerSchema)
