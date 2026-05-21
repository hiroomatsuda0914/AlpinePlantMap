# Alpine Plant Map — Claude Code メモ

## AIへの作業ルール
- ソースコードを直接編集しない
- 実装方針の提案・設計アドバイス・チャット上でのコード例の提示に徹する

## 技術スタック
- Flutter (Dart) / flutter_map + Mapbox タイル（Web）
- 状態管理: Riverpod + Notifier（MVVM）
- バックエンド: Supabase（PostgreSQL + PostGIS / Storage）
- 環境変数: `--dart-define-from-file=.env`（VSCodeはlaunch.json設定済み）

## 実装進捗

### 完了済み
- Supabaseスキーマ作成（posts / likes / follows テーブル、インデックス、RLSポリシー）
- `lib/features/map/domain/post.dart` — Post モデル + IconCategory enum（flower / foliage / berry / snow / plant / mushroom / mountain / hut / other）
- `lib/features/map/domain/filter_state.dart` — FilterState モデル
- `lib/features/map/domain/post_draft.dart` — PostDraft モデル（投稿下書き状態）
- `lib/features/map/presentation/post_creation_notifier.dart` — PostCreationNotifier（写真選択・EXIF抽出・アイコン/タグ操作）
- `pubspec.yaml` — supabase_flutter / flutter_riverpod / image_picker / flutter_image_compress / exif 追加済み
- `main.dart` — Supabase.initialize() + ProviderScope 追加・起動確認済み

### 次のステップ（ここから再開）

#### ▶ 今すぐやること: `post_creation_sheet.dart` を完成させる
- ファイル: `lib/features/map/presentation/post_creation_sheet.dart`
- 状況: 実装途中（全体構造・アイコン仕様データ・メインシートは記述済み）
- 残り: `_Step1Photo` / `_Step2Icon` / `_Step3Tags` / `_Step4Confirm` の各ウィジェット実装
- 完成後: `map_screen.dart` に FAB を追加 → `showModalBottomSheet` で呼び出せば動作確認できる

#### その次: `post_repository.dart` を作る
- ファイル: `lib/features/map/data/post_repository.dart`
- 内容: 投稿一覧取得（fetchPosts）+ 画像アップロード + INSERT メソッド
- 完成後: `post_creation_notifier.dart` の `submitPost()` を実装して投稿できるようになる

### その後
- PostRepository と Notifier が繋がったら `submitPost()` を実装 → 投稿できるようになる
- FilterNotifier 作成（`lib/features/map/presentation/filter_notifier.dart`）
- 地図にピンを表示（ゴール）
- Google Cloud Vision API 連携（植物タグ自動認識）

## フォルダ構成（現状）
```
lib/features/map/
  domain/
    post.dart            ✓
    filter_state.dart    ✓
    post_draft.dart      ✓
  data/
    post_repository.dart ← 未着手
  presentation/
    map_screen.dart      ✓（既存）
    post_creation_notifier.dart ✓
    post_creation_sheet.dart    実装途中
    filter_notifier.dart        ← 後から
```

## クラウドサービス連携（実装予定）

### Google Cloud Vision API — 植物タグ自動認識
投稿時に写真からAIが植物タグ候補を自動提案する機能。ポートフォリオの目玉として採用。

**設計方針**
- APIキー保護のため **Supabase Edge Functions** を中継レイヤーに使用
- Flutter → Edge Function → Vision API → タグ候補返却 → 投稿ダイアログに自動セット

**実装タイミング**: Step E（地図ピン表示）完了後に着手する
