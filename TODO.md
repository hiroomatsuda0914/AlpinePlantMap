# Alpine Plant Map — 実装 TODO

凡例: ✅ 完了 / 🔄 進行中 / ⬜ 未着手

---

## Step A — 新カテゴリ追加（水場・崩落）

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| A-1 | `IconCategory` enum に `water`, `trailDamage` を追加 | `domain/post.dart` | ✅ |
| A-2 | `_iconSpecs` に `water`, `trailDamage` を追加 | `presentation/post_creation_sheet.dart` | ✅ |

---

## Step B — 投稿ダイアログの完成

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| B-0 | `dart:io` の `File` を `XFile` に置き換え（Web対応） | `domain/post_draft.dart`, `presentation/post_creation_sheet.dart`, `presentation/post_creation_notifier.dart` | ✅ |
| B-1 | `_Step2Icon` 実装（カテゴリグリッド・状態/色チップ・群落トグル） | `presentation/post_creation_sheet.dart` | ✅ |
| B-2 | `_Step3Tags` 実装（植物タグ・場所タグ入力） | `presentation/post_creation_sheet.dart` | 🔄 |
| B-3 | `_Step4Confirm` 実装（確認サマリー） | `presentation/post_creation_sheet.dart` | ⬜ |
| B-4 | `_canGoNext()` を汎用化（色なしカテゴリ対応） | `presentation/post_creation_sheet.dart` | ✅ |

---

## Step C — 地図からシートを開けるようにする

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| C-1 | FAB を追加してボトムシートを開く | `web_map_screen.dart` | ⬜ |

---

## Step D — 投稿の保存

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| D-1 | 画像を Supabase Storage にアップロード | `data/post_repository.dart` | ⬜ |
| D-2 | 投稿を DB に INSERT | `data/post_repository.dart` | ⬜ |
| D-3 | `submitPost()` を実装 | `presentation/post_creation_notifier.dart` | ⬜ |

---

## Step E — 地図にピン表示

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| E-1 | `FilterNotifier` を作成 | `presentation/filter_notifier.dart` | ⬜ |
| E-2 | `fetchPosts()` にフィルタ条件を適用 | `data/post_repository.dart` | ⬜ |
| E-3 | 投稿をピン/写真として地図に表示 | `web_map_screen.dart` | ⬜ |
| E-4 | クラスタリング実装（広域:数字丸 / 中域:代表写真 / 拡大:全表示） | `web_map_screen.dart` | ⬜ |

---

## Step F — Google Cloud Vision API 連携（最後）

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| F-1 | Supabase Edge Function 作成（`functions/analyze-plant/`） | — | ⬜ |
| F-2 | Step3 に「タグを自動取得」ボタンを追加 | `presentation/post_creation_sheet.dart` | ⬜ |

---

## 技術的負債

| # | 内容 | 優先度 |
|---|---|---|
| T-1 | `dart:io` の `File` を `XFile` に置き換え（Webでクラッシュする） | 高（Step B 前に対処） |
