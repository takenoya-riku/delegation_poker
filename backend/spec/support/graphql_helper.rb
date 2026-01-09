module GraphQLHelper
  # GraphQLリクエストをHTTP経由で送信するヘルパー
  #
  # @param query [String] GraphQLクエリ文字列
  # @param variables [Hash, String, nil] 変数（Hash、JSON文字列、またはnil）
  # @param operation_name [String, nil] オペレーション名
  # @return [ActionDispatch::TestResponse] レスポンスオブジェクト
  #
  # @example 基本的なクエリ
  #   post_graphql(query: "{ testField }")
  #
  # @example 変数付きクエリ
  #   post_graphql(query: "query($id: ID!) { user(id: $id) { name } }", variables: { id: "1" })
  #
  # @example オペレーション名付きクエリ
  #   post_graphql(query: "query GetUser { user { name } }", operation_name: "GetUser")
  def post_graphql(query:, variables: nil, operation_name: nil)
    params = { query: query }
    params[:variables] = variables if variables.present?
    params[:operationName] = operation_name if operation_name.present?

    post '/graphql', params: params, as: :json
  end

  # GraphQLミューテーションをHTTP経由で送信するヘルパー
  #
  # @param mutation [String] GraphQLミューテーション文字列
  # @param variables [Hash, String, nil] 変数（Hash、JSON文字列、またはnil）
  # @return [ActionDispatch::TestResponse] レスポンスオブジェクト
  #
  # @example
  #   post_graphql_mutation(mutation: "mutation { createUser(name: \"John\") { id } }")
  def post_graphql_mutation(mutation:, variables: nil)
    post_graphql(query: mutation, variables: variables)
  end

  # GraphQLレスポンスのJSONをパースして返すヘルパー
  #
  # @param response [ActionDispatch::TestResponse] レスポンスオブジェクト
  # @return [Hash] パースされたJSONレスポンス
  #
  # @example
  #   response = post_graphql(query: "{ testField }")
  #   json = graphql_response(response)
  #   expect(json['data']['testField']).to eq('Hello World!')
  def graphql_response(response)
    JSON.parse(response.body)
  end
end

RSpec.configure do |config|
  config.include GraphQLHelper, type: :request
end
