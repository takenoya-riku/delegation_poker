# Delegation Poker

Rails 8 API + Nuxt 3 + PostgreSQL アプリケーション

## プロジェクト構成

- **バックエンド**: Rails 8 (APIモード)
- **フロントエンド**: Nuxt 3
- **データベース**: PostgreSQL 15

バックエンドとデータベースはDocker Composeで管理され、フロントエンドはローカルで実行します。

## セットアップ

### 1. 環境変数の設定

プロジェクトルートに`.env`ファイルを作成し、以下の内容を設定してください：

```bash
# PostgreSQL設定
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_DB=delegation_poker_development
POSTGRES_PORT=5433

# Rails設定
RAILS_ENV=development
RAILS_PORT=3001

# Nuxt設定（フロントエンド用）
NUXT_PUBLIC_API_BASE_URL=http://localhost:3001

# CORS設定（Rails用）
FRONTEND_URL=http://localhost:8088
```

`.env.example`を参考にしてください。

### 2. バックエンドのセットアップ

#### Docker Composeで起動

```bash
docker-compose up -d
```

初回起動時は、データベースのマイグレーションを実行してください：

```bash
docker-compose exec rails rails db:create db:migrate
```

#### バックエンドのログ確認

```bash
docker-compose logs -f rails
```

### 3. フロントエンドのセットアップ

```bash
cd frontend
npm install
npm run dev
```

フロントエンドは`http://localhost:8088`でアクセスできます。

## 開発

### バックエンド（Rails API）

- APIエンドポイント: `http://localhost:3001`
- ヘルスチェック: `http://localhost:3001/up`
- GraphQLエンドポイント: `http://localhost:3001/graphql`
- GraphiQL IDE: `http://localhost:3001/graphiql` (開発環境のみ)

### フロントエンド（Nuxt 3）

- 開発サーバー: `http://localhost:8088`
- APIベースURLは環境変数`NUXT_PUBLIC_API_BASE_URL`で設定されます

## GraphQL

このプロジェクトはGraphQLを使用しています。

### バックエンド（Rails）

GraphQLスキーマは`backend/app/graphql/`ディレクトリに定義されています。

- `delegation_poker_schema.rb`: メインスキーマ
- `types/query_type.rb`: クエリ定義
- `types/mutation_type.rb`: ミューテーション定義

### フロントエンド（Nuxt）

urqlを使用してGraphQLに接続します。

#### GraphQL Code Generator

スキーマからTypeScriptの型を自動生成します：

```bash
cd frontend
npm run codegen
```

ウォッチモードで実行する場合：

```bash
npm run codegen:watch
```

生成された型は`frontend/graphql/generated/types.ts`に出力されます。

#### GraphQLクエリの作成

`frontend/graphql/`ディレクトリに`.graphql`ファイルを作成してください。

例: `frontend/graphql/test.query.graphql`
```graphql
query TestQuery {
  testField
}
```

#### urqlの使用例

```vue
<script setup lang="ts">
import { useQuery } from '@urql/vue'
import { TestQueryDocument } from '~/graphql/generated/types'

const { data, fetching, error } = useQuery({
  query: TestQueryDocument
})
</script>

<template>
  <div v-if="fetching">Loading...</div>
  <div v-else-if="error">Error: {{ error.message }}</div>
  <div v-else>{{ data?.testField }}</div>
</template>
```

## Docker Composeコマンド

```bash
# サービス起動
docker-compose up -d

# サービス停止
docker-compose down

# ログ確認
docker-compose logs -f

# Railsコンソール起動
docker-compose exec rails rails console

# データベースマイグレーション
docker-compose exec rails rails db:migrate

# データベースリセット
docker-compose exec rails rails db:reset
```

## ディレクトリ構造

```
delegation_poker/
├── backend/              # Rails 8 APIアプリケーション
│   ├── app/
│   │   ├── graphql/      # GraphQLスキーマとタイプ定義
│   │   ├── controllers/
│   │   └── ...
│   ├── config/
│   ├── Dockerfile
│   └── Gemfile
├── frontend/            # Nuxt 3アプリケーション
│   ├── graphql/         # GraphQLクエリ/ミューテーションファイル
│   │   └── generated/   # Code Generatorで生成された型定義
│   ├── plugins/         # Nuxtプラグイン（urqlクライアントなど）
│   ├── app.vue
│   ├── codegen.yml      # GraphQL Code Generator設定
│   ├── nuxt.config.ts
│   └── package.json
├── docker-compose.yml   # Docker Compose設定
├── .env.example         # 環境変数テンプレート
└── README.md
```

## トラブルシューティング

### PostgreSQL接続エラー

`.env`ファイルのデータベース設定を確認してください。Docker Composeのサービス名`postgres`が`DATABASE_HOST`として使用されます。

### CORSエラー

`backend/config/initializers/cors.rb`でフロントエンドのURLが許可されているか確認してください。デフォルトでは`http://localhost:8088`が許可されています。環境変数`FRONTEND_URL`で変更できます。

### ポート競合

`.env`ファイルでポート番号を変更できます：
- `RAILS_PORT`: Rails APIのポート（デフォルト: 3001）
- `POSTGRES_PORT`: PostgreSQLのポート（デフォルト: 5433）
- フロントエンドのポートは`frontend/package.json`の`dev`スクリプトで`--port`オプションを指定して変更できます（デフォルト: 8088）