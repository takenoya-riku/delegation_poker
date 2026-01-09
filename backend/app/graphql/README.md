# GraphQL API

このディレクトリには、GraphQLスキーマとタイプ定義が含まれています。

## ディレクトリ構造

```
app/graphql/
├── delegation_poker_schema.rb  # メインスキーマ定義
├── mutations/                   # ミューテーション定義
├── queries/                     # クエリ定義
└── types/                       # 型定義
    ├── base_object.rb          # ベースオブジェクト型
    ├── base_enum.rb            # ベース列挙型
    ├── base_input_object.rb    # ベース入力オブジェクト型
    ├── base_scalar.rb          # ベーススカラー型
    ├── mutation_type.rb        # ミューテーション型
    └── query_type.rb           # クエリ型
```

## 使用方法

### エンドポイント

- **GraphQLエンドポイント**: `POST /graphql`
- **GraphiQL IDE**: `GET /graphiql` (開発環境のみ)

### クエリの例

```graphql
query {
  testField
}
```

### ミューテーションの例

```graphql
mutation {
  testMutation
}
```

## 開発ガイド

新しいフィールドを追加する際は、適切な型定義ファイルに追加してください。
