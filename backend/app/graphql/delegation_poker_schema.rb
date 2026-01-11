class DelegationPokerSchema < GraphQL::Schema
  mutation(Types::Root::MutationType)
  query(Types::Root::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    if err.is_a?(GraphQL::InvalidNullError)
      Rails.logger.warn(
        "GraphQL invalid null error: #{err.message}",
      )
    end

    super
  end

  # Stop validating when it encounters this many errors:
  validate_max_errors(100)
end
