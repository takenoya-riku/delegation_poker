# Delegation Poker 仕様書

## 1. 概要

### 1.1 目的

Delegation Pokerは、チーム内での権限委譲レベルを可視化し、意思決定の透明性を高めるためのWebアプリケーションです。参加者はトピックに対して1-7の権限委譲レベルで投票し、結果を共有して議論を促進します。

### 1.2 主要機能

- ルームの作成と参加
- 話し合いたい対象出し
- 対象の整理（統合・編集・削除）
- 現状確認の投票（権限委譲レベル1-7）
- 理想の投票（権限委譲レベル1-7）
- 参加者の削除（ルームマスターのみ）
- 投票結果の公開と統計表示
- リアルタイム更新（ポーリング）

### 1.3 技術スタック

- **バックエンド**: Rails 8 (API mode)
- **フロントエンド**: Nuxt 3
- **データベース**: PostgreSQL 15
- **API**: GraphQL
- **状態管理**: urql (Vue)
- **スタイリング**: Tailwind CSS + DaisyUI

## 2. データモデル

### 2.1 Room（ルーム）

- **目的**: 議論の単位となるルーム
- **属性**:
  - `id`: UUID（主キー）
  - `name`: ルーム名（必須）
  - `code`: 6桁の英数字コード（必須、一意、自動生成）
  - `room_master_id`: ルームマスターの参加者ID（任意）
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `has_many :participants`
  - `has_many :topics`
  - `belongs_to :room_master`（任意）
- **ビジネスロジック**:
  - 作成時に6桁のランダムコードを自動生成（大文字英数字）
  - コードは一意である必要がある
  - 参加者が初めて参加したタイミングでルームマスターを設定

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
  - ルームマスターは参加者を削除可能（自身は削除不可）

### 2.3 Topic（トピック）

- **目的**: 議論するトピック
- **属性**:
  - `id`: UUID（主キー）
  - `room_id`: UUID（外部キー）
  - `participant_id`: UUID（外部キー、作成者）
  - `title`: タイトル（必須）
  - `description`: 説明（オプション）
  - `status`: ステータス（デフォルト: `draft`）
    - `draft`: 対象出しフェーズ
    - `organizing`: 整理フェーズ
    - `current_voting`: 現状確認投票中
    - `current_revealed`: 現状確認結果公開済み
    - `desired_voting`: 理想投票中
    - `desired_revealed`: 理想結果公開済み
    - `completed`: 完了
  - `created_at`, `updated_at`: タイムスタンプ
- **関連**:
  - `belongs_to :room`
  - `belongs_to :participant`（任意）
  - `has_many :votes`
- **ビジネスロジック**:
  - 作成時は`draft`ステータス
  - 対象出しフェーズは作成者のみ編集・削除可能
  - 整理フェーズはルームマスターのみ編集・削除可能
  - フェーズ遷移メソッド: `start_organizing!`, `start_current_voting!`, `reveal_current_state!`, `start_desired_voting!`, `reveal_desired_state!`, `complete!`
  - `all_participants_voted_current_state?`で現状確認の投票完了を判定
  - `all_participants_voted_desired_state?`で理想の投票完了を判定

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
  - トピック、参加者、vote_typeの組み合わせは一意（同じ参加者は1つのトピックに対して現状確認と理想の2回投票可能）
  - 現状確認投票はトピックが`current_voting`ステータスの場合のみ可能
  - 理想投票はトピックが`desired_voting`ステータスの場合のみ可能
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
  - `roomMasterId`を含めて返す

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

#### deleteRoom

- **説明**: ルームを削除
- **引数**:
  - `room_id: ID!`: ルームID
  - `participant_id: ID!`: 参加者ID
- **戻り値**:
  - `success: Boolean!`: 成功フラグ
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 参加者がルームに属している必要がある
  - ルームマスターのみ削除可能

#### removeParticipant

- **説明**: ルームから参加者を削除
- **引数**:
  - `room_id: ID!`: ルームID
  - `participant_id: ID!`: 操作する参加者ID
  - `target_participant_id: ID!`: 削除対象の参加者ID
- **戻り値**:
  - `success: Boolean!`: 成功フラグ
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - ルームマスターのみ削除可能
  - ルームマスター自身は削除不可

#### addTopic

- **説明**: ルームにトピックを追加（対象出し）
- **引数**:
  - `room_id: ID!`: ルームID
  - `participant_id: ID!`: 参加者ID
  - `title: String!`: トピックタイトル
  - `description: String`: 説明（オプション）
- **戻り値**:
  - `topic: TopicType`: 作成されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 作成時は`draft`ステータス

#### updateTopic

- **説明**: トピックを編集する（対象出し/整理フェーズ用）
- **引数**:
  - `topic_id: ID!`: トピックID
  - `participant_id: ID!`: 参加者ID
  - `title: String`: タイトル（オプション）
  - `description: String`: 説明（オプション）
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 対象出しフェーズは作成者のみ編集可能
  - 整理フェーズは参加者なら編集可能

#### deleteTopic

- **説明**: トピックを削除する（対象出し/整理フェーズ用）
- **引数**:
  - `topic_id: ID!`: トピックID
  - `participant_id: ID!`: 参加者ID
- **戻り値**:
  - `success: Boolean!`: 成功フラグ
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 対象出しフェーズは作成者のみ削除可能
  - 整理フェーズは参加者なら削除可能

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

#### startOrganizing

- **説明**: トピックを対象出しフェーズから整理フェーズに移行する
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 対象出しフェーズ（`draft`）のトピックを整理フェーズ（`organizing`）に移行
  - トピックが`draft`ステータスである必要がある

#### organizeTopic

- **説明**: トピックを整理フェーズから現状投票フェーズに移行する
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 整理フェーズ（`organizing`）のトピックを現状投票フェーズ（`current_voting`）に移行
  - トピックが`organizing`ステータスである必要がある

#### revertToDraft

- **説明**: トピックを整理フェーズから対象出しフェーズに戻す
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 整理フェーズ（`organizing`）のトピックのみ対象出しに戻せる

#### revertToOrganizing

- **説明**: トピックを投票フェーズから整理フェーズに戻す
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - 投票フェーズのトピックのみ整理フェーズに戻せる
  - 投票データは削除される

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
  - 理想投票はトピックが`desired_voting`ステータスである必要がある

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

- **説明**: 理想投票フェーズを開始する
- **引数**:
  - `topic_id: ID!`: トピックID
- **戻り値**:
  - `topic: TopicType`: 更新されたトピック（null可能）
  - `errors: [String!]!`: エラーメッセージ配列
- **ビジネスロジック**:
  - トピックが`current_revealed`ステータスである必要がある
  - ステータスを`desired_voting`に変更

#### revealDesiredState

- **説明**: 理想の投票結果を公開
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

1. トップページでルーム名と参加者名を入力
2. `createRoom` mutationを実行
3. 成功時、作成者を参加者として自動登録（`joinRoom`を内部実行）
4. ルーム作成者を「ルームマスター」として記録
5. ルームページ（`/room/{code}`）にリダイレクト
6. 参加者IDをローカル/セッションストレージに保存

### 4.2 ルーム参加フロー

1. トップページでルームコードと参加者名を入力
2. `joinRoom` mutationを実行
3. 成功時、ルームページ（`/room/{code}`）にリダイレクト
4. 参加者IDをローカル/セッションストレージに保存

### 4.3 ルームページフロー

1. ルームコードでルーム情報を取得（`room` query）
2. 5秒ごとにポーリングして最新情報を取得
3. 参加者一覧を表示
4. ルーム情報をローカルに保存し、保存済みルーム一覧（`/rooms`）に表示
5. フェーズに応じたUIを表示：
   - **対象出しフェーズ**: 対象の追加・確認
   - **整理フェーズ**: 統合・編集・削除
   - **投票フェーズ**: 投票ボードで投票・結果表示（権限レベルカードは画面上部に追従表示）

### 4.4 対象出しフロー

1. `TopicDraftList`でトピックタイトルと説明を入力
2. `addTopic` mutationを実行（status: `draft`）
3. 追加された対象を確認
4. 「整理フェーズに進む」ボタンで`startOrganizing` mutationを実行し、すべての`draft`トピックを`organizing`に移行

### 4.5 整理フロー

1. `TopicOrganizeView`で対象一覧を表示
2. 重複や類似の対象を統合（`mergeTopics` mutation）
3. 対象を編集（`updateTopic` mutation、ルームマスターのみ）
4. 不要な対象を削除（`deleteTopic` mutation、ルームマスターのみ）
5. 必要に応じて対象出しに戻す（`revertToDraft` mutation）
6. 「投票に進む」ボタンで`organizeTopic` mutationを実行し、すべての`organizing`トピックを`current_voting`に移行

### 4.6 現状確認投票フロー

1. 投票ボードで「現状確認」の投票UIを表示
2. 1-7のボタンから選択
3. `vote` mutationを実行（`vote_type: CURRENT_STATE`）
4. 既存の投票がある場合は公開前に限り更新可能
5. 公開前は自分の投票のみ表示し、公開後は全員分を表示
6. 全参加者が投票完了後、「現状確認結果を公開」ボタンで公開（`revealCurrentState` mutation）
7. 必要に応じて整理フェーズに戻す（`revertToOrganizing` mutation、投票データは削除）
8. 投票結果のCSVを出力可能

### 4.7 理想投票フロー

1. 現状確認結果公開後、「理想投票を開始」ボタンで開始（`startDesiredStateVoting` mutation）
2. 投票ボードで「理想」の投票UIを表示
3. 1-7のボタンから選択
4. `vote` mutationを実行（`vote_type: DESIRED_STATE`）
5. 既存の投票がある場合は公開前に限り更新可能
6. 公開前は自分の投票のみ表示し、公開後は全員分を表示
7. 全参加者が投票完了後、「理想結果を公開」ボタンで公開（`revealDesiredState` mutation）
8. 現状確認と理想の結果を比較表示

### 4.8 参加者削除フロー

1. ルームマスターが参加者一覧から削除ボタンを選択
2. `removeParticipant` mutationを実行
3. 成功時に参加者一覧を再取得

## 5. ビジネスロジック

### 5.1 ルーム管理

- ルームは6桁のランダムコードで識別
- コードは大文字小文字を区別しない検索が可能
- ルームはルームマスターのみ削除可能
- 参加者の削除はルームマスターのみ可能（自身は削除不可）

### 5.2 フェーズ管理

- **対象出しフェーズ**: トピックを追加（status: `draft`）
- **整理フェーズ**: トピックを統合・編集・削除（status: `organizing`、編集・削除はルームマスターのみ）
- **現状確認投票フェーズ**: 現状確認の投票を実施（status: `current_voting`）
- **現状確認結果公開**: 現状確認の結果を公開（status: `current_revealed`）
- **理想投票フェーズ**: 理想の投票を実施（status: `desired_voting`）
- **理想結果公開**: 理想の結果を公開（status: `desired_revealed`）
- **フェーズ移行操作**: ルームマスターのみが実行可能（整理フェーズ開始、現状確認投票開始）

### 5.3 投票管理

- 1つのトピックに対して1人の参加者は現状確認と理想の2回投票可能（各1回、公開前は更新可能）
- 現状確認投票はトピックが`current_voting`ステータスの場合のみ可能
- 理想投票はトピックが`desired_voting`ステータスの場合のみ可能
- 投票結果が公開されると、そのフェーズの新しい投票は不可
- 公開前は自分の投票のみ表示し、公開後に全員の投票結果を表示

### 5.4 結果公開

- 現状確認結果公開: トピックのステータスを`current_voting`から`current_revealed`に変更
- 理想結果公開: トピックのステータスを`desired_voting`から`desired_revealed`に変更
- 公開後は以下の統計情報を表示：
  - 平均投票レベル（`average_vote_level`）
  - 最小投票レベル（`min_vote_level`）
  - 最大投票レベル（`max_vote_level`）
  - 全参加者の投票完了状況（`all_participants_voted`）

### 5.5 リアルタイム更新

- ルームページは5秒ごとにポーリング
- 新しい参加者の追加、トピックの追加、投票の更新を自動反映

## 6. セキュリティと制約

### 6.1 認証認可

- 現時点では認証認可機能は未実装
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

## 8. UI/UXデザイン

### 8.1 デザイン方針

- **モダンでプレイフル**: カラフルなグラデーションとアニメーションを活用した親しみやすいデザイン
- **視覚的階層**: フェーズごとに異なるカラーテーマを適用し、現在のフェーズを明確に表示
- **レスポンシブ**: モバイルデバイスでも美しく表示される設計
- **アクセシブル**: 視認性と使いやすさを維持

### 8.2 デザイン要素

- **グラデーション背景**: ページ全体に柔らかいグラデーション背景を適用
- **カラフルなカード**: 各コンポーネントをカード形式で表示し、ホバーエフェクトを追加
- **フェーズごとのカラーテーマ**:
  - `draft`: グレー系
  - `organizing`: イエロー/オレンジ系
  - `current_voting`: ブルー/シアン系
  - `current_revealed`: グリーン系
  - `desired_voting`: パープル/ピンク系
  - `desired_revealed`: インディゴ系
  - `completed`: グレー系
- **アニメーション**: フェードイン、スライドイン、パルスグローなどのスムーズなアニメーション
- **グラデーションボタン**: 主要なアクションにグラデーションボタンを使用

## 9. 将来の拡張可能性

### 9.1 認証認可

- ユーザー認証機能の追加
- ルーム作成者・管理者の概念
- 権限ベースのアクセス制御

### 9.2 機能拡張

- WebSocketによるリアルタイム更新（ポーリングの代替）
- ルームのアーカイブ機能
- 投票履歴の表示
- コメント機能
- トピックの編集・削除機能

## 10. 技術的な詳細

### 10.1 アーキテクチャ

- **バックエンド**: Service Objectパターンでビジネスロジックを分離
- **フロントエンド**: Composition APIを使用したコンポーネント設計
- **状態管理**: urqlによるGraphQLクライアント状態管理

### 10.2 データベース設計

- UUIDを主キーとして使用
- 外部キー制約による参照整合性
- インデックスによる検索性能の最適化

### 10.3 テスト戦略

- Request Spec（HTTP経由の統合テスト）
- GraphQL結合テスト（スキーマ直接実行）
- 単体テスト（モデル、サービスオブジェクト）
