# テスト仕様

このディレクトリには、RSpecテストが含まれています。

## テスト戦略

このプロジェクトでは、以下の3層のテスト戦略を採用しています：

1. **Request Spec（統合テスト）**: ControllerをHTTP経由でテスト
2. **GraphQL結合テスト**: ResolverやMutationをスキーマ直接実行でテスト
3. **単体テスト**: モデル、サービスオブジェクトなどのpublicメソッドをテスト

**注意**: テストファイル内の`it`と`context`のテキストは全て日本語で記述します。

## ディレクトリ構造

```
spec/
├── requests/              # Request specs（HTTP経由のテスト）
│   └── graphql_controller_spec.rb
├── graphql/               # GraphQL結合テスト
│   ├── queries/           # Query resolverのテスト
│   │   └── query_type_spec.rb
│   └── mutations/         # Mutation resolverのテスト
│       └── mutation_type_spec.rb
├── models/                # モデルの単体テスト
├── services/              # サービスオブジェクトの単体テスト
├── support/               # テストヘルパーと設定
│   ├── factory_bot.rb
│   ├── graphql_helper.rb          # Request spec用ヘルパー
│   ├── graphql_schema_helper.rb  # GraphQL結合テスト用ヘルパー
│   └── shoulda_matchers.rb
├── factories/             # Factory定義
├── rails_helper.rb        # Rails用テストヘルパー
└── spec_helper.rb         # RSpec基本設定
```

## テストヘルパー

### Request Spec用ヘルパー (`spec/support/graphql_helper.rb`)

HTTP経由でGraphQLリクエストを送信するためのヘルパー：

- `post_graphql(query:, variables: nil, operation_name: nil)` - GraphQLクエリをHTTP経由で送信
- `post_graphql_mutation(mutation:, variables: nil)` - GraphQLミューテーションをHTTP経由で送信
- `graphql_response(response)` - レスポンスのJSONをパース

### GraphQL結合テスト用ヘルパー (`spec/support/graphql_schema_helper.rb`)

GraphQLスキーマを直接実行するためのヘルパー：

- `execute_graphql(query:, variables: {}, context: {}, operation_name: nil)` - GraphQLスキーマを直接実行
- `execute_mutation(mutation:, variables: {}, context: {})` - GraphQLミューテーションを直接実行
- `graphql_data(result)` - 実行結果からデータを取得
- `graphql_errors(result)` - 実行結果からエラーを取得

詳細は`docs/development/testing.md`を参照してください。
