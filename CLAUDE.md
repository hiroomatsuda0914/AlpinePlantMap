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
- 状況: `_IconSpec` クラスと `_iconSpecs` データのみ記述済み（27行）。それ以降は未実装
- コード例: 直前のセッション（2026-05-22）でチャット上に完全なコード例を提示済み
  - `PostCreationSheet`（DraggableScrollableSheet + 4ステップナビゲーション）
  - `_Step1Photo`（写真選択 + EXIF GPS 表示）
  - `_Step2Icon`（カテゴリグリッド + 状態/色チップ + 群落トグル）
  - `_Step3Tags`（植物タグ・場所タグ入力）
  - `_Step4Confirm`（確認サマリー + 投稿ボタン ※submitPost は TODO）
  - `_InfoRow` / `_TagInput` / `_ConfirmRow` ヘルパーウィジェット
- 完成後: `web_map_screen.dart` または `mobile_map_screen.dart` の Scaffold に FAB を追加
  ```dart
  floatingActionButton: FloatingActionButton(
    onPressed: () => showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const PostCreationSheet(),
    ),
    child: const Icon(Icons.add),
  ),
  ```

#### その次: `post_repository.dart` を充実させる
- ファイル: `lib/features/map/data/post_repository.dart`
- 状況: `fetchPosts(FilterState)` のみ実装済み（フィルタ未適用の全件取得）
- 残り: 画像アップロード（Supabase Storage）+ INSERT メソッド
- 完成後: `post_creation_notifier.dart` の `submitPost()` を実装して投稿できるようになる

### その後
- PostRepository と Notifier が繋がったら `submitPost()` を実装 → 投稿できるようになる
- FilterNotifier 作成（`lib/features/map/presentation/filter_notifier.dart`）
- 地図にピンを表示（ゴール）
- Google Cloud Vision API 連携（植物タグ自動認識）

## フォルダ構成（現状）
```
lib/features/map/
  map_screen.dart              ✓（プラットフォーム振り分け）
  web_map_screen.dart          ✓
  mobile_map_screen.dart       ✓
  domain/
    post.dart                  ✓
    filter_state.dart          ✓
    post_draft.dart            ✓
  data/
    post_repository.dart       △（fetchPosts のみ。upload/INSERT は未実装）
  presentation/
    post_creation_notifier.dart ✓
    post_creation_sheet.dart    ← コード例提示済み・写経して追記する
    filter_notifier.dart        ← 後から
```

## クラウドサービス連携（実装予定）

### Google Cloud Vision API — 植物タグ自動認識
投稿時に写真からAIが植物タグ候補を自動提案する機能。ポートフォリオの目玉として採用。

**設計方針**
- APIキー保護のため **Supabase Edge Functions** を中継レイヤーに使用
- Flutter → Edge Function → Vision API → タグ候補返却 → 投稿ダイアログに自動セット

**実装タイミング**: Step E（地図ピン表示）完了後に着手する
