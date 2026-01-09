# ドキュメント管理ガイド

このディレクトリには、プロジェクトの詳細なドキュメントを管理します。

## ドキュメント構造

```
docs/
├── README.md              # このファイル（ドキュメント管理ガイド）
├── architecture/          # アーキテクチャ設計ドキュメント
│   ├── backend.md         # バックエンド設計
│   ├── frontend.md        # フロントエンド設計
│   └── database.md        # データベース設計
├── api/                   # API仕様書
│   └── graphql.md         # GraphQL API仕様
├── development/           # 開発ガイド
│   ├── setup.md           # セットアップ手順
│   ├── testing.md         # テストガイド
│   └── deployment.md      # デプロイ手順
└── decisions/             # アーキテクチャ決定記録（ADR）
    └── README.md          # ADR一覧
```

## Cursorでのドキュメント管理のベストプラクティス

### 1. 階層的なREADME構造

- **プロジェクトルートのREADME.md**: プロジェクト全体の概要、クイックスタート
- **各ディレクトリのREADME.md**: ディレクトリの目的と構造
- **docs/ディレクトリ**: 詳細なドキュメント

### 2. コードとドキュメントの近接性

重要なコードの近くにドキュメントを配置：
- `backend/app/graphql/README.md` - GraphQLスキーマの説明
- `backend/spec/README.md` - テスト戦略の説明
- `frontend/components/README.md` - コンポーネント設計

### 3. Cursorの機能を活用

- **@ファイル名**: ドキュメントを参照して質問
- **@docs**: docsディレクトリ全体を参照
- **コードコメント**: 複雑なロジックには詳細なコメント

### 4. ドキュメントの更新

- コード変更時にドキュメントも更新
- **設計変更（アーキテクチャ、ディレクトリ構造、設計原則など）は必ずドキュメントに反映する**
- GraphQLの構造変更時は`backend/app/graphql/README.md`を更新する
- PR/MRの際にドキュメント更新を確認
- 定期的なドキュメントレビュー

### 5. バージョン管理

- ドキュメントもGitで管理
- 変更履歴を追跡
- 重要な変更はCHANGELOG.mdに記録
