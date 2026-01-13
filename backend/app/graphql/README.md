# GraphQL API

このディレクトリには、GraphQLスキーマとタイプ定義が含まれています。

## ディレクトリ構造

```
app/graphql/
├── delegation_poker_schema.rb  # メインスキーマ定義
├── mutations/                   # ミューテーション定義
│   ├── base_mutation.rb        # ミューテーションのベースクラス
│   └── *.rb                    # 個別のミューテーションクラス
├── queries/                     # クエリ定義
│   ├── base_query.rb           # クエリのベースクラス
│   └── *.rb                    # 個別のクエリクラス
└── types/                       # 型定義
    ├── base/                    # ベースクラス
    │   ├── base_object.rb
    │   ├── base_enum.rb
    │   ├── base_input_object.rb
    │   └── base_scalar.rb
    ├── root/                     # ルート型
    │   ├── mutation_type.rb     # ミューテーション型（mutations/を参照）
    │   └── query_type.rb        # クエリ型（queries/を参照）
    ├── objects/                  # Object型
    │   └── *.rb                 # 個別のObject型（RoomType, ParticipantTypeなど）
    └── enums/                    # 列挙型
        └── *.rb                 # 個別の列挙型
```

## 設計原則

### MutationsとQueriesの構造

このプロジェクトでは、**mutationsとqueriesディレクトリ配下の構成は、テスト（`spec/graphql/`）とAPI（`app/graphql/`）で一致させる**ことを原則としています。

- **Mutations**: `app/graphql/mutations/`に個別のmutationクラスを定義し、`types/mutation_type.rb`で参照
- **Queries**: `app/graphql/queries/`に個別のqueryクラスを定義し、`types/query_type.rb`で参照

### 新しいMutation/Queryの追加方法

1. **Mutationの場合**:
   - `app/graphql/mutations/`に新しいmutationクラスを作成（`BaseMutation`を継承）
   - `app/graphql/types/mutation_type.rb`に`field`を追加

2. **Queryの場合**:
   - `app/graphql/queries/`に新しいqueryクラスを作成（`BaseQuery`を継承）
   - `app/graphql/types/query_type.rb`に`field`を追加

3. **テストの追加**:
   - `spec/graphql/mutations/`または`spec/graphql/queries/`に対応するテストファイルを作成
   - APIとテストのディレクトリ構造を一致させる

## 使用方法

### エンドポイント

- **GraphQLエンドポイント**: `POST /graphql`
- **GraphiQL IDE**: `GET /graphiql` (開発環境のみ)

### クエリの例

```graphql
query GetRoom($code: String!) {
  room(code: $code) {
    id
    name
    code
    participants {
      id
      name
    }
    topics {
      id
      title
      status
      participantId
    }
  }
}
```

### ミューテーションの例

```graphql
mutation CreateRoom($name: String!) {
  createRoom(name: $name) {
    room {
      id
      name
      code
    }
    errors
  }
}
```

```graphql
mutation AddTopic($roomId: ID!, $participantId: ID!, $title: String!, $description: String) {
  addTopic(roomId: $roomId, participantId: $participantId, title: $title, description: $description) {
    topic {
      id
      title
      status
      participantId
    }
    errors
  }
}
```

```graphql
mutation RevertToDraft($topicId: ID!) {
  revertToDraft(topicId: $topicId) {
    topic {
      id
      status
    }
    errors
  }
}
```

## 開発ガイド

### 新しいMutationの追加例

```ruby
# app/graphql/mutations/create_room.rb
module Mutations
  class CreateRoom < BaseMutation
    description "新しいルームを作成する"

    argument :name, String, required: true, description: "ルーム名"

    field :room, Types::Objects::RoomType, null: true
    field :errors, [String], null: false

    def resolve(name:)
      # TODO: 認証認可の実装
      # authorize! :create, Room

      result = CreateRoomService.call(name: name)

      {
        room: result[:room],
        errors: result[:errors]
      }
    end
  end
end
```

**注意**: Mutation/Resolverでは、ビジネスロジックはServiceクラスに委譲し、認証認可・serviceクラスの呼び出し・簡単なデータ取得のみを行います。

```ruby
# app/graphql/types/mutation_type.rb
field :create_room, mutation: Mutations::CreateRoom
```

### 新しいQueryの追加例

```ruby
# app/graphql/queries/room_query.rb
module Queries
  class RoomQuery < BaseQuery
    description "ルームコードでルーム情報を取得する"

    type Types::Objects::RoomType, null: true

    argument :code, String, required: true, description: "ルームコード"

    def resolve(code:)
      Room.find_by(code: code.upcase)
    end
  end
end
```

```ruby
# app/graphql/types/query_type.rb
field :room, resolver: Queries::RoomQuery
```

### テストの追加

APIとテストのディレクトリ構造を一致させるため、以下のようにテストファイルを作成します：

- Mutation: `spec/graphql/mutations/create_room_spec.rb`
- Query: `spec/graphql/queries/room_query_spec.rb`
