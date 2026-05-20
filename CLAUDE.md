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
- `lib/features/map/domain/post.dart` — Post モデル + IconCategory enum
- `lib/features/map/domain/filter_state.dart` — FilterState モデル
- `pubspec.yaml` — supabase_flutter / flutter_riverpod / image_picker / flutter_image_compress / exif 追加済み
- `main.dart` — Supabase.initialize() + ProviderScope 追加・起動確認済み

### 次のステップ（ここから再開）
**Step C: PostRepository 作成**
- ファイル: `lib/features/map/data/post_repository.dart`
- 内容: Supabaseから投稿一覧を取得するメソッド
- 完成するとDBにテストデータを入れれば地図にピンが表示できる状態になる

### その後
- Step D: FilterNotifier 作成（`lib/features/map/presentation/`）
- Step E: 地図にピンを表示（ゴール）

## フォルダ構成（目標）
```
lib/features/map/
  domain/
    post.dart          ✓
    filter_state.dart  ✓
  data/
    post_repository.dart  ← 次回
  presentation/
    map_screen.dart（既存）
    filter_notifier.dart  ← 後から
```
