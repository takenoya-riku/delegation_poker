# Frontend

Nuxt 3 フロントエンドアプリケーション

## セットアップ

```bash
npm install
```

## 開発サーバー起動

```bash
npm run dev
```

開発サーバーは`http://localhost:8088`で起動します。

## ビルド

```bash
npm run build
```

## Lint

```bash
npm run lint
```

```bash
npm run lint:fix
```
`lint:fix` では ESLint と型チェックを実行します。

## テスト

```bash
npm run test
```

## Storybook

```bash
npm run storybook
```

## 開発ルール

- 新しいコンポーネントを作成したら、対応する Storybook のストーリーも作成する
- フロントエンドに機能追加を行ったら、必ずテストを実装する

## テスト構造

- テストは `tests/` 配下に配置する
- ページは `tests/pages/`、コンポーネントは `tests/components/`、composables は `tests/composables/` に分けて管理する

## Storybook 構造

- Storybook の設定は `.storybook/` 配下に配置する
- コンポーネントの Story は `components/` 配下で管理する
