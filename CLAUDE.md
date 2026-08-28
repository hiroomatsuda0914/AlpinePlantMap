# Alpine Plant Map — Claude Code メモ

## AIへの作業ルール
- ソースコードを直接編集しない（ユーザーが明示的に依頼した場合を除く）
- 実装方針の提案・設計アドバイス・チャット上でのコード例の提示に徹する
- 案内は一度に1ステップずつ出す（複数の修正を一度に列挙しない）

## 参照ファイル
- 機能仕様・アーキテクチャ・アイコン定義: `DESIGN.md`
- 実装 TODO と進捗: `TODO.md`

## 技術スタック
- Flutter (Dart) / flutter_map + Mapbox タイル（Web優先）
- 状態管理: Riverpod + Notifier（MVVM）
- バックエンド: Supabase（PostgreSQL + PostGIS / Storage）
- 環境変数: `--dart-define-from-file=.env`（VSCode は launch.json 設定済み）
