# テストガイド

## テスト戦略

このプロジェクトでは、以下の3層のテスト戦略を採用しています：

1. **Request Spec（統合テスト）**: ControllerをHTTP経由でテスト
2. **GraphQL結合テスト**: ResolverやMutationをスキーマ直接実行でテスト
3. **単体テスト**: モデル、サービスオブジェクトなどのpublicメソッドをテスト

**注意**: テストファイル内の`it`と`context`のテキストは全て日本語で記述します。

> **参考**: 基本的なテスト戦略とルールは`.cursorrules`に記載されています。詳細な説明、コード例、実行方法はこのドキュメントを参照してください。

## テスト構成

### 1. Request Spec（統合テスト）

**場所**: `spec/requests/`

ControllerをHTTP経由でテストします。**Controllerの責務のみをテスト**し、具体的なGraphQLロジック（mutationやresolver）のテストは行いません。

**テスト内容**:
- HTTPリクエストの処理
- レスポンスのステータスコードと形式
- パラメータのパース（変数の文字列/ハッシュ）
- エラーハンドリング

**使用ヘルパー**: `spec/support/graphql_helper.rb`

```ruby
# spec/requests/graphql_controller_spec.rb
RSpec.describe GraphqlController, type: :request do
  describe 'POST /graphql' do
    it '成功レスポンスを返す' do
      post_graphql(query: "{ room(code: \"ABC123\") { id } }")
      
      expect(response).to have_http_status(:success)
      expect(response.content_type).to include('application/json')
    end
  end
end
```

**実行方法**:
```bash
docker compose exec api rspec spec/requests/
```

### 2. GraphQL結合テスト

**場所**: `spec/graphql/`

**全てのResolverとMutationをGraphQLスキーマを直接実行してテストします**。HTTPレイヤーを経由せず、GraphQLのロジックを検証します。

**テスト対象**:
- 全てのMutations（createRoom, joinRoom, addTopic, vote, revealTopic）
- 全てのQueries（room）

**使用ヘルパー**: `spec/support/graphql_schema_helper.rb`

```ruby
# spec/graphql/mutations/create_room_spec.rb
RSpec.describe Mutations::CreateRoom, type: :graphql do
  it 'ルームを作成する' do
    result = execute_mutation(
      mutation: "mutation { createRoom(name: \"Test\") { room { code } } }"
    )
    
    data = graphql_data(result)
    expect(data['createRoom']['room']['code']).to be_present
  end
end
```

```ruby
# spec/graphql/queries/room_query_spec.rb
RSpec.describe 'Room Query', type: :graphql do
  it 'ルームコードでルーム情報を取得する' do
    room = create(:room)
    result = execute_graphql(
      query: "query { room(code: \"#{room.code}\") { name } }"
    )
    
    data = graphql_data(result)
    expect(data['room']['name']).to eq(room.name)
  end
end
```

**実行方法**:
```bash
docker compose exec api rspec spec/graphql/
```

### 3. 単体テスト

**場所**: `spec/models/`, `spec/services/`, など

モデルやサービスオブジェクトのpublicメソッドを直接テストします。

**重要**: **privateメソッドは検証しません**。privateメソッドはpublicメソッドを通じて間接的にテストされます。

```ruby
# spec/models/user_spec.rb
RSpec.describe User, type: :model do
  describe '#full_name' do
    it 'フルネームを返す' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

```ruby
# spec/services/user_creator_spec.rb
RSpec.describe UserCreator do
  describe '.call' do
    it '新しいユーザーを作成する' do
      result = UserCreator.call(name: 'John')
      expect(result.success?).to be true
      expect(result.user).to be_persisted
    end
  end
end
```

**実行方法**:
```bash
docker compose exec api rspec spec/models/
docker compose exec api rspec spec/services/
```

## テストヘルパー

### Request Spec用ヘルパー (`spec/support/graphql_helper.rb`)

- `post_graphql(query:, variables: nil, operation_name: nil)` - GraphQLクエリをHTTP経由で送信
- `post_graphql_mutation(mutation:, variables: nil)` - GraphQLミューテーションをHTTP経由で送信
- `graphql_response(response)` - レスポンスのJSONをパース

### GraphQL結合テスト用ヘルパー (`spec/support/graphql_schema_helper.rb`)

- `execute_graphql(query:, variables: {}, context: {}, operation_name: nil)` - GraphQLスキーマを直接実行
- `execute_mutation(mutation:, variables: {}, context: {})` - GraphQLミューテーションを直接実行
- `graphql_data(result)` - 実行結果からデータを取得
- `graphql_errors(result)` - 実行結果からエラーを取得

## テスト実行

### すべてのテストを実行

```bash
docker compose exec api rspec
```

### 特定のタイプのテストを実行

```bash
# Request specのみ
docker compose exec api rspec spec/requests/

# GraphQL結合テストのみ
docker compose exec api rspec spec/graphql/

# 単体テストのみ
docker compose exec api rspec spec/models/ spec/services/
```

### 特定のファイルを実行

```bash
docker compose exec api rspec spec/requests/graphql_controller_spec.rb
```

### 特定のテストを実行

```bash
docker compose exec api rspec spec/requests/graphql_controller_spec.rb:6
```

## テストの書き方

### Request Specの例

```ruby
require 'rails_helper'

RSpec.describe GraphqlController, type: :request do
  describe 'POST /graphql' do
    context 'リクエストが有効な場合' do
      it '成功レスポンスを返す' do
        room = create(:room)
        post_graphql(query: "{ room(code: \"#{room.code}\") { id } }")
        
        expect(response).to have_http_status(:success)
        expect(response.content_type).to include('application/json')
      end
    end
  end
end
```

### GraphQL結合テストの例

```ruby
require 'rails_helper'

RSpec.describe Mutations::CreateRoom, type: :graphql do
  describe '#resolve' do
    it 'ルームを作成する' do
      result = execute_mutation(
        mutation: <<~GRAPHQL,
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
        GRAPHQL
        variables: { name: 'Test Room' }
      )
      
      data = graphql_data(result)
      expect(data['createRoom']['room']['name']).to eq('Test Room')
      expect(data['createRoom']['room']['code']).to be_present
    end
  end
end
```

### 単体テストの例

```ruby
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:email) }
  end
  
  describe '#full_name' do
    it 'フルネームを返す' do
      user = build(:user, first_name: 'John', last_name: 'Doe')
      expect(user.full_name).to eq('John Doe')
    end
  end
end
```

## テストディレクトリ構造

```
spec/
├── requests/              # Request specs（HTTP経由のテスト、Controllerのみ）
│   └── graphql_controller_spec.rb
├── graphql/               # GraphQL結合テスト（全てのmutationとresolver）
│   ├── queries/           # Query resolverのテスト
│   └── mutations/         # Mutation resolverのテスト
├── models/                # モデルの単体テスト
├── services/               # サービスオブジェクトの単体テスト
├── support/               # テストヘルパーと設定
│   ├── factory_bot.rb
│   ├── graphql_helper.rb      # Request spec用ヘルパー
│   ├── graphql_schema_helper.rb # GraphQL結合テスト用ヘルパー
│   └── shoulda_matchers.rb
└── factories/             # Factory定義
```
