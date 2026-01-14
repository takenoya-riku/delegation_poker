# Delegation Poker

Rails 8 API + Nuxt 3 + PostgreSQL アプリケーション

## プロジェクト構成

- **バックエンド**: Rails 8 (APIモード)
- **フロントエンド**: Nuxt 3
- **データベース**: PostgreSQL 15

バックエンドとデータベースはDocker Composeで管理され、フロントエンドはローカルで実行します。

## セットアップ

### 0. Voltaの準備

このプロジェクトはVoltaでNode.js環境を管理します。事前にVoltaをインストールし、Node.jsとnpmを準備してください。

```bash
volta install node
volta install npm
```

### 1. 環境変数の設定

プロジェクトルートに`.env`ファイルを作成し、以下の内容を設定してください：

```bash
cp .env.example .env
```

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
docker compose up -d
```

初回起動時は、データベースのマイグレーションを実行してください：

```bash
docker compose exec api rails db:create db:migrate
```

#### バックエンドのログ確認

```bash
docker compose logs -f api
```

### 3. フロントエンドのセットアップ

```bash
cd frontend
npm install
# GraphQL Code Generatorで型定義を生成
npm run codegen
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

**ディレクトリ構造**:
- `mutations/`: 個別のミューテーション定義
- `queries/`: 個別のクエリ定義
- `types/`: 型定義
  - `base/`: ベースクラス
  - `root/`: ルート型
  - `objects/`: Object型
  - `enums/`: 列挙型

**設計原則**: mutationsとqueriesディレクトリ配下の構成は、テスト（`spec/graphql/`）とAPI（`app/graphql/`）で一致させます。

詳細は`backend/app/graphql/README.md`を参照してください。

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
docker compose up -d

# サービス停止
docker compose down

# ログ確認
docker compose logs -f

# Railsコンソール起動
docker compose exec api rails console

# データベースマイグレーション
docker compose exec api rails db:migrate

# データベースリセット
docker compose exec api rails db:reset

# テスト実行
docker compose exec api rspec

# RuboCop実行（コードスタイルチェック）
docker compose exec api rubocop

# RuboCop自動修正
docker compose exec api rubocop -a
```

## ディレクトリ構造

```
delegation_poker/
├── backend/              # Rails 8 APIアプリケーション
│   ├── app/
│   │   ├── graphql/      # GraphQLスキーマとタイプ定義
│   │   ├── services/     # Serviceクラス（ビジネスロジック）
│   │   ├── controllers/
│   │   └── ...
│   ├── config/
│   ├── db/
│   ├── spec/             # RSpecテスト
│   │   ├── requests/     # Request specs（HTTP経由のテスト）
│   │   ├── graphql/      # GraphQL結合テスト
│   │   ├── models/       # モデルの単体テスト
│   │   └── services/     # サービスオブジェクトの単体テスト
│   └── ...
├── frontend/             # Nuxt 3アプリケーション
│   ├── components/       # Vueコンポーネント
│   │   ├── features/     # 機能単位のコンポーネント
│   │   └── ui/           # UIパーツのコンポーネント
│   ├── graphql/          # GraphQLクエリ/ミューテーションファイル
│   ├── plugins/          # Nuxtプラグイン（urqlクライアントなど）
│   └── ...
├── docs/                 # 詳細なドキュメント
│   └── development/      # 開発ガイド
│       └── ...
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

## コードスタイル

このプロジェクトでは、RuboCopとESLintでコードスタイルを統一しています。

### RuboCopの実行

```bash
# コードスタイルチェック
docker compose exec api rubocop

# 自動修正可能な問題を修正
docker compose exec api rubocop -a

# 特定のファイルをチェック
docker compose exec api rubocop app/models/room.rb
```

### RuboCop設定

RuboCopの設定は`.rubocop.yml`に記載されています。主な設定：

- Ruby 3.3をターゲット
- 行の最大長: 120文字（specファイルを除く）
- Rails向けのルールを有効化
- RSpec向けのルールを有効化

### ESLintの実行

```bash
cd frontend
npm run lint
npm run lint:fix
```

## Delegation Pokerの使い方

### ワークフロー

Delegation Pokerは以下の4つのフェーズで進行します：

1. **話し合いたい対象出し（Draft）**
   - ルームに参加後、トピックタイトルと説明を入力して追加
   - 複数の対象を追加可能
   - 「整理フェーズに進む」ボタンで次へ

2. **対象の整理（Organizing）**
   - 追加された対象を確認
   - 重複や類似の対象を統合・編集・削除
   - 「投票に進む」ボタンで次へ

3. **現状確認（投票）**
   - 各対象に対して権限委譲レベル（1-7）で投票
   - 公開前は自分の投票のみ確認でき、公開後に全員の投票結果を表示
   - 投票は公開前に限り変更可能
   - 全員が投票完了後、「現状確認結果を公開」ボタンで結果を公開
   - 必要に応じて整理フェーズに戻せる（投票データはリセット）
   - トピックと投票結果のCSVを出力できる

4. **ありたい姿（投票）**
   - 「ありたい姿投票を開始」ボタンで開始
   - 現状確認と同様に1-7のレベルで投票
   - 公開前は自分の投票のみ確認でき、公開後に全員の投票結果を表示
   - 投票は公開前に限り変更可能
   - 全員が投票完了後、「ありたい姿結果を公開」ボタンで結果を公開
   - 現状確認とありたい姿の結果を比較表示

### 権限委譲レベル

- **レベル1**: Tell（指示）
- **レベル2**: Sell（説得）
- **レベル3**: Consult（相談）
- **レベル4**: Agree（合意）
- **レベル5**: Advise（助言）
- **レベル6**: Inquire（確認）
- **レベル7**: Delegate（委譲）

## テスト

このプロジェクトでは、以下の3層のテスト戦略を採用しています：

1. **Request Spec（統合テスト）**: ControllerをHTTP経由でテスト
2. **GraphQL結合テスト**: ResolverやMutationをスキーマ直接実行でテスト
3. **単体テスト**: モデル、サービスオブジェクトなどのpublicメソッドをテスト

テストファイル内の`it`と`context`のテキストは全て日本語で記述します。

詳細は[テストガイド](docs/development/testing.md)を参照してください。

## ドキュメント

詳細なドキュメントは`docs/`ディレクトリを参照してください：

- [アプリケーション仕様書](docs/specification.md)
- [ドキュメント管理ガイド](docs/README.md)
- [テストガイド](docs/development/testing.md)
- [GraphQL API仕様](backend/app/graphql/README.md)
- [テスト仕様](backend/spec/README.md)

## Cursorでのドキュメント管理

このプロジェクトでは、以下の方法でドキュメントを管理しています：

1. **プロジェクトルートのREADME.md**: プロジェクト全体の概要とクイックスタート
2. **docs/ディレクトリ**: 詳細なドキュメント（アーキテクチャ、API仕様、開発ガイドなど）
3. **各ディレクトリのREADME.md**: ディレクトリの目的と構造の説明
4. **AGENTS.md**: エージェント用のプロジェクトルール

### Cursorでの活用方法

- `@docs` - docsディレクトリ全体を参照して質問
- `@README.md` - READMEを参照して質問
- `@ファイル名` - 特定のドキュメントを参照して質問
- コードコメント - 複雑なロジックには詳細なコメントを追加
