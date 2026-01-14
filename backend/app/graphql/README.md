# GraphQL API

このディレクトリには、GraphQLスキーマとタイプ定義が含まれています。

## ディレクトリ構造

```
app/graphql/
├── mutations/                   # ミューテーション定義
├── queries/                     # クエリ定義
└── types/                       # 型定義
    ├── base/                    # ベースクラス
    ├── root/                    # ルート型
    ├── objects/                 # Object型
    └── enums/                   # 列挙型
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
   - `spec/graphql/`配下の対応ディレクトリにテストを追加
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
    roomMasterId
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
mutation RemoveParticipant($roomId: ID!, $participantId: ID!, $targetParticipantId: ID!) {
  removeParticipant(roomId: $roomId, participantId: $participantId, targetParticipantId: $targetParticipantId) {
    success
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

```graphql
mutation RevertToOrganizing($topicId: ID!) {
  revertToOrganizing(topicId: $topicId) {
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

APIとテストのディレクトリ構造を一致させるため、MutationとQueryのディレクトリ対応を維持します。

### 参加者削除の設計方針

ルームから参加者を削除するMutationはルームマスターのみ実行できます。
ルームマスター自身は削除できません。
