module GraphQLSchemaHelper
  # GraphQLスキーマを直接実行するヘルパー（結合テスト用）
  #
  # @param query [String] GraphQLクエリ文字列
  # @param variables [Hash, nil] 変数（Hash）
  # @param context [Hash, nil] GraphQLコンテキスト
  # @param operation_name [String, nil] オペレーション名
  # @return [GraphQL::Query::Result] GraphQL実行結果
  #
  # @example 基本的なクエリ
  #   result = execute_graphql(query: "{ testField }")
  #   expect(result['data']['testField']).to eq('Hello World!')
  #
  # @example 変数付きクエリ
  #   result = execute_graphql(
  #     query: "query($id: ID!) { user(id: $id) { name } }",
  #     variables: { id: "1" }
  #   )
  #
  # @example コンテキスト付きクエリ
  #   result = execute_graphql(
  #     query: "{ currentUser { name } }",
  #     context: { current_user: user }
  #   )
  def execute_graphql(query:, variables: {}, context: {}, operation_name: nil)
    DelegationPokerSchema.execute(
      query,
      variables: variables,
      context: context,
      operation_name: operation_name,
    )
  end

  # GraphQLミューテーションを直接実行するヘルパー（結合テスト用）
  #
  # @param mutation [String] GraphQLミューテーション文字列
  # @param variables [Hash, nil] 変数（Hash）
  # @param context [Hash, nil] GraphQLコンテキスト
  # @return [GraphQL::Query::Result] GraphQL実行結果
  #
  # @example
  #   result = execute_mutation(
  #     mutation: "mutation { createUser(name: \"John\") { id } }"
  #   )
  def execute_mutation(mutation:, variables: {}, context: {})
    execute_graphql(query: mutation, variables: variables, context: context)
  end

  # GraphQL実行結果からデータを取得するヘルパー
  #
  # @param result [GraphQL::Query::Result] GraphQL実行結果
  # @return [Hash, nil] データ部分
  #
  # @example
  #   result = execute_graphql(query: "{ testField }")
  #   data = graphql_data(result)
  #   expect(data['testField']).to eq('Hello World!')
  def graphql_data(result)
    result["data"]
  end

  # GraphQL実行結果からエラーを取得するヘルパー
  #
  # @param result [GraphQL::Query::Result] GraphQL実行結果
  # @return [Array, nil] エラー配列
  #
  # @example
  #   result = execute_graphql(query: "{ invalidField }")
  #   errors = graphql_errors(result)
  #   expect(errors).to be_present
  def graphql_errors(result)
    result["errors"]
  end
end

RSpec.configure do |config|
  config.include GraphQLSchemaHelper, type: :graphql
end
