# Delegation Poker 仕様書

## 1. 概要

### 1.1 目的

Delegation Pokerは、チーム内での権限委譲レベルを可視化し、意思決定の透明性を高めるためのWebアプリケーションです。参加者はトピックに対して1-7の権限委譲レベルで投票し、結果を共有して議論を促進します。

### 1.2 主要機能

- ルームの作成と参加
- 話し合いたい対象出し
- 対象の整理（統合・編集・削除）
- 現状確認の投票（権限委譲レベル1-7）
- ありたい姿の投票（権限委譲レベル1-7）
- 投票結果の公開と統計表示
- リアルタイム更新（ポーリング）

### 1.3 技術スタック

- **バックエンド**: Rails 8 (API mode)
- **フロントエンド**: Nuxt 3
- **データベース**: PostgreSQL 15
- **API**: GraphQL
- **状態管理**: urql (Vue)

## 2. データモデル

### 2.1 Room（ルーム）

- **目的**: 議論の単位となるルーム
- **属性**:
  - `id`: UUID（主キー）
  - `name`: ルーム名（必須）
  - `code`: 6桁の英数字コード（必須、一意、自動生成）
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `has_many :participants`
  - `has_many :topics`
- **ビジネスロジック**:
  - 作成時に6桁のランダムコードを自動生成（大文字英数字）
  - コードは一意である必要がある

### 2.2 Participant（参加者）

- **目的**: ルームに参加するメンバー
- **属性**:
  - `id`: UUID（主キー）
  - `room_id`: UUID（外部キー）
  - `name`: 参加者名（必須）
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `belongs_to :room`
  - `has_many :votes`
- **ビジネスロジック**:
  - 同じルーム内で同じ名前の参加者が複数存在可能

### 2.3 Topic（トピック）

- **目的**: 議論するトピック
- **属性**:
  - `id`: UUID（主キー）
  - `room_id`: UUID（外部キー）
  - `title`: タイトル（必須）
  - `description`: 説明（オプション）
  - `status`: ステータス（デフォルト: `draft`）
    - `draft`: 対象出しフェーズ
    - `organizing`: 整理フェーズ
    - `current_voting`: 現状確認投票中
    - `current_revealed`: 現状確認結果公開済み
    - `desired_voting`: ありたい姿投票中
    - `desired_revealed`: ありたい姿結果公開済み
    - `completed`: 完了
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `belongs_to :room`
  - `has_many :votes`
- **ビジネスロジック**:
  - 作成時は`draft`ステータス
  - フェーズ遷移メソッド: `start_organizing!`, `start_current_voting!`, `reveal_current_state!`, `start_desired_voting!`, `reveal_desired_state!`, `complete!`
  - `all_participants_voted_current_state?`で現状確認の投票完了を判定
  - `all_participants_voted_desired_state?`でありたい姿の投票完了を判定

### 2.4 Vote（投票）

- **目的**: トピックに対する権限委譲レベルの投票
- **属性**:
  - `id`: UUID（主キー）
  - `topic_id`: UUID（外部キー）
  - `participant_id`: UUID（外部キー）
  - `level`: 権限委譲レベル（1-7、必須）
  - `vote_type`: 投票の種類（`current_state`または`desired_state`、必須）
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `belongs_to :topic`
  - `belongs_to :participant`
- **ビジネスロジック**:
  - トピック、参加者、vote_typeの組み合わせは一意（同じ参加者は1つのトピックに対して現状確認とありたい姿の2回投票可能）
  - 現状確認投票はトピックが`current_voting`ステータスの場合のみ可能
  - ありたい姿投票はトピックが`desired_voting`ステータスの場合のみ可能
  - レベルは1-7の範囲

### 2.5 Delegation Level（権限委譲レベル）

- **レベル1**: Tell（指示）
- **レベル2**: Sell（説得）
- **レベル3**: Consult（相談）
- **レベル4**: Agree（合意）
- **レベル5**: Advise（助言）
- **レベル6**: Inquire（確認）
- **レベル7**: Delegate（委譲）

## 3. GraphQL API仕様

### 3.1 Queries

#### room

- **説明**: ルームコードでルーム情報を取得
- **引数**:
  - `code: String!`: ルームコード
- **戻り値**: `RoomType`（null可能）
- **ビジネスロジック**:
  - 大文字小文字を区別しない検索
  - 存在しない場合は`null`を返す

### 3.2 Mutations

#### createRoom

- **説明**: 新しいルームを作成
- **引数**:
  - `name: String!`: ルーム名
- **戻り値**:
  - `room: RoomType!`: 作成されたルーム
  - `errors: [String!]!`: エラーメッセージ配列

#### joinRoom

- **説明**: 既存のルームに参加
- **引数**:
  - `code: String!`: ルームコード
  - `name: String!`: 参加者名
- **戻り値**:
  - `room: RoomType`: 参加したルーム（null可能）
  - `participant: ParticipantType`: 作成された参加者（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - ルームコードは大文字小文字を区別しない
  - ルームが存在しない場合はエラー

#### addTopic

- **説明**: ルームにトピックを追加（対象出し）
- **引数**:
  - `room_id: ID!`: ルームID
  - `title: String!`: トピックタイトル
  - `description: String`: 説明（オプション）
- **戻り値**:
  - `topic: TopicType`: 作成されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 作成時は`draft`ステータス

#### updateTopic

- **説明**: トピックを編集する（整理フェーズ用）
- **引数**:
  - `topic_id: ID!`: トピックID
  - `title: String`: タイトル（オプション）
  - `description: String`: 説明（オプション）
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 整理フェーズ（`organizing`）のトピックのみ編集可能

#### deleteTopic

- **説明**: トピックを削除する（整理フェーズ用）
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `success: Boolean!`: 成功フラグ
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 整理フェーズ（`organizing`）のトピックのみ削除可能

#### mergeTopics

- **説明**: トピックを統合する（整理フェーズ用）
- **引数**:
  - `source_topic_id: ID!`: 統合元のトピックID
  - `target_topic_id: ID!`: 統合先のトピックID
- **戻り値**:
  - `topic: TopicType`: 統合後のトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 整理フェーズ（`organizing`）のトピックのみ統合可能
  - 同じルームのトピックのみ統合可能

#### organizeTopic

- **説明**: トピックを整理フェーズから現状投票フェーズに移行する
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 対象出しフェーズ（`draft`）のトピックを整理フェーズ（`organizing`）に移行後、現状投票フェーズ（`current_voting`）に移行

#### vote

- **説明**: トピックに投票
- **引数**:
  - `topic_id: ID!`: トピックID
  - `participant_id: ID!`: 参加者ID
  - `level: Int!`: 権限委譲レベル（1-7）
  - `vote_type: VoteTypeEnum!`: 投票の種類（`CURRENT_STATE`または`DESIRED_STATE`）
- **戻り値**:
  - `vote: VoteType`: 作成/更新された投票（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 既存の投票がある場合は更新
  - トピックと参加者が同じルームに属している必要がある
  - 現状確認投票はトピックが`current_voting`ステータスである必要がある
  - ありたい姿投票はトピックが`desired_voting`ステータスである必要がある

#### revealCurrentState

- **説明**: 現状確認の投票結果を公開
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - トピックが`current_voting`ステータスである必要がある
  - ステータスを`current_revealed`に変更

#### startDesiredStateVoting

- **説明**: ありたい姿投票フェーズを開始する
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - トピックが`current_revealed`ステータスである必要がある
  - ステータスを`desired_voting`に変更

#### revealDesiredState

- **説明**: ありたい姿の投票結果を公開
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - トピックが`desired_voting`ステータスである必要がある
  - ステータスを`desired_revealed`に変更

#### revealTopic

- **説明**: トピックの投票結果を公開（後方互換性のため残存）
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - トピックの現在のステータスに応じて適切な公開処理を実行

## 4. UI/UXフロー

### 4.1 ルーム作成フロー

1. トップページでルーム名を入力
2. `createRoom` mutationを実行
3. 成功時、ルームページ（`/room/{code}`）にリダイレクト
4. 参加者IDをローカルストレージに保存

### 4.2 ルーム参加フロー

1. トップページでルームコードと参加者名を入力
2. `joinRoom` mutationを実行
3. 成功時、ルームページ（`/room/{code}`）にリダイレクト
4. 参加者IDをローカルストレージに保存

### 4.3 ルームページフロー

1. ルームコードでルーム情報を取得（`room` query）
2. 5秒ごとにポーリングして最新情報を取得
3. 参加者一覧を表示
4. フェーズに応じたUIを表示：
   - **対象出しフェーズ**: `TopicDraftList`コンポーネントで対象を追加・確認
   - **整理フェーズ**: `TopicOrganizeView`コンポーネントで統合・編集・削除
   - **投票フェーズ**: `TopicCard`コンポーネントで投票・結果表示

### 4.4 対象出しフロー

1. `TopicDraftList`でトピックタイトルと説明を入力
2. `addTopic` mutationを実行（status: `draft`）
3. 追加された対象を確認
4. 「整理フェーズに進む」ボタンで整理フェーズに移行

### 4.5 整理フロー

1. `TopicOrganizeView`で対象一覧を表示
2. 重複や類似の対象を統合（`mergeTopics` mutation）
3. 対象を編集（`updateTopic` mutation）
4. 不要な対象を削除（`deleteTopic` mutation）
5. 「現状確認投票に進む」ボタンで投票フェーズに移行（`organizeTopic` mutation）

### 4.6 現状確認投票フロー

1. トピックカードで「現状確認」の投票UIを表示
2. 1-7のボタンから選択
3. `vote` mutationを実行（`vote_type: CURRENT_STATE`）
4. 既存の投票がある場合は更新
5. 全参加者が投票完了後、「現状確認結果を公開」ボタンで公開（`revealCurrentState` mutation）

### 4.7 ありたい姿投票フロー

1. 現状確認結果公開後、「ありたい姿投票を開始」ボタンで開始（`startDesiredStateVoting` mutation）
2. トピックカードで「ありたい姿」の投票UIを表示
3. 1-7のボタンから選択
4. `vote` mutationを実行（`vote_type: DESIRED_STATE`）
5. 既存の投票がある場合は更新
6. 全参加者が投票完了後、「ありたい姿結果を公開」ボタンで公開（`revealDesiredState` mutation）
7. 現状確認とありたい姿の結果を比較表示

## 5. ビジネスロジック

### 5.1 ルーム管理

- ルームは6桁のランダムコードで識別
- コードは大文字小文字を区別しない検索が可能
- ルームは永続的に保存され、削除機能はない（現時点）

### 5.2 フェーズ管理

- **対象出しフェーズ**: トピックを追加（status: `draft`）
- **整理フェーズ**: トピックを統合・編集・削除（status: `organizing`）
- **現状確認投票フェーズ**: 現状確認の投票を実施（status: `current_voting`）
- **現状確認結果公開**: 現状確認の結果を公開（status: `current_revealed`）
- **ありたい姿投票フェーズ**: ありたい姿の投票を実施（status: `desired_voting`）
- **ありたい姿結果公開**: ありたい姿の結果を公開（status: `desired_revealed`）

### 5.3 投票管理

- 1つのトピックに対して1人の参加者は現状確認とありたい姿の2回投票可能（各1回、更新は可能）
- 現状確認投票はトピックが`current_voting`ステータスの場合のみ可能
- ありたい姿投票はトピックが`desired_voting`ステータスの場合のみ可能
- 投票結果が公開されると、そのフェーズの新しい投票は不可

### 5.4 結果公開

- 現状確認結果公開: トピックのステータスを`current_voting`から`current_revealed`に変更
- ありたい姿結果公開: トピックのステータスを`desired_voting`から`desired_revealed`に変更
- 公開後は以下の統計情報を表示：
  - 平均投票レベル（`average_vote_level`）
  - 最小投票レベル（`min_vote_level`）
  - 最大投票レベル（`max_vote_level`）
  - 全参加者の投票完了状況（`all_participants_voted`）

### 5.4 リアルタイム更新

- ルームページは5秒ごとにポーリング
- 新しい参加者の追加、トピックの追加、投票の更新を自動反映

## 6. セキュリティと制約

### 6.1 認証認可

- 現時点では認証認可機能は未実装（TODOコメントあり）
- 将来的な実装を想定した設計

### 6.2 データ整合性

- トピックと参加者が同じルームに属していることを投票時に検証
- トピックのステータスを投票時に検証
- 投票レベルの範囲（1-7）を検証

### 6.3 バリデーション

- ルーム名は必須
- 参加者名は必須
- トピックタイトルは必須
- 投票レベルは1-7の範囲

## 7. エラーハンドリング

### 7.1 GraphQLエラー

- すべてのmutationは`errors`フィールドを返す
- エラーがある場合、`success: false`とエラーメッセージ配列を返す
- フロントエンドでエラーメッセージを表示

### 7.2 一般的なエラーケース

- ルームが見つからない
- トピックが見つからない
- 参加者が見つからない
- トピックと参加者が異なるルームに属している
- トピックが既に公開済み
- 無効な投票レベル

## 8. 将来の拡張可能性

### 8.1 認証認可

- ユーザー認証機能の追加
- ルーム作成者・管理者の概念
- 権限ベースのアクセス制御

### 8.2 機能拡張

- WebSocketによるリアルタイム更新（ポーリングの代替）
- ルームの削除・アーカイブ機能
- 投票履歴の表示
- コメント機能
- トピックの編集・削除機能

## 9. 技術的な詳細

### 9.1 アーキテクチャ

- **バックエンド**: Service Objectパターンでビジネスロジックを分離
- **フロントエンド**: Composition APIを使用したコンポーネント設計
- **状態管理**: urqlによるGraphQLクライアント状態管理

### 9.2 データベース設計

- UUIDを主キーとして使用
- 外部キー制約による参照整合性
- インデックスによる検索性能の最適化

### 9.3 テスト戦略

- Request Spec（HTTP経由の統合テスト）
- GraphQL結合テスト（スキーマ直接実行）
- 単体テスト（モデル、サービスオブジェクト）
