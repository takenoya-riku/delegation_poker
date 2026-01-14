# Cursor Rules for Delegation Poker Project

## ドキュメント管理

- 重要な変更は必ずドキュメントを更新する
- **設計変更（アーキテクチャ、ディレクトリ構造、設計原則など）は必ずドキュメントに反映する**
- コードコメントは「なぜ」を説明する（「何を」はコードが示す）
- 複雑なロジックには詳細なコメントを追加
- README.mdは最新の状態を保つ
- GraphQLの構造変更時は`backend/app/graphql/README.md`を更新する
- **ディレクトリ構造を記載する際は、個別のファイル名は記載しない（ディレクトリ構造のみ）**
- **新しいコンポーネントを作成したら、対応するStorybookのストーリーも作成する**
- **フロントエンドに機能追加を行ったら、必ずテストを実装する**

## コードスタイル

- Ruby: RuboCopの推奨スタイルに従う
- TypeScript/JavaScript: ESLintの推奨スタイルに従う
- GraphQL: スキーマは明確で一貫性のある命名規則を使用
- フロントエンドのAPI取得はPagesディレクトリのみで行う。共通化が必要な場合はcomposablesに実装する

## テスト

- 新しい機能には必ずテストを追加
- フロントエンドを更新した際は必ず`npm run lint:fix`を実行する
- バックエンドを更新した際は必ず`rspec`と`rubocop -a`を実行する
- マイグレーションファイルを変更した際は`rails db:migrate`とGraphQLスキーマの更新（`rails graphql:schema:dump`）を行う
- テスト戦略: Request Spec（統合テスト）、GraphQL結合テスト、単体テストの3層構造
- Request Spec: ControllerをHTTP経由でテスト（`spec/requests/`）
- GraphQL結合テスト: ResolverやMutationをスキーマ直接実行でテスト（`spec/graphql/`）
- 単体テスト: モデル、サービスオブジェクトなどのpublicメソッドをテスト（`spec/models/`, `spec/services/`）
- **単体テストではprivateメソッドは検証しない**（privateメソッドはpublicメソッドを通じて間接的にテストされる）
- テストファイル内の`it`と`context`のテキストは全て日本語で記述
- GraphQLテストは`post_graphql`ヘルパー（Request Spec）または`execute_graphql`ヘルパー（結合テスト）を使用

## Serviceクラス

- Serviceクラスを作成する際は必ず`Service`モジュールを`include`し、`call`メソッドをインスタンスメソッドとして実装する
- Serviceクラスの呼び出しは必ず`call`メソッドを使用する（`ServiceClass.call(...)`）
- Resolver/Mutationは薄い層とし、認証認可・serviceクラスの呼び出し・簡単なデータ取得のみを行う
- ビジネスロジックはすべてServiceクラスに実装する

## Git

- コミットメッセージは明確で説明的に
- 大きな変更は複数のコミットに分割
- ドキュメントの変更もコミットに含める
