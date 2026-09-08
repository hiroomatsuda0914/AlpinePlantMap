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
| B-2 | `_Step3Tags` 実装（植物タグ・場所タグ入力） | `presentation/post_creation_sheet.dart` | ✅ |
| B-3 | `_Step4Confirm` 実装（確認サマリー） | `presentation/post_creation_sheet.dart` | ✅ |
| B-4 | `_canGoNext()` を汎用化（色なしカテゴリ対応） | `presentation/post_creation_sheet.dart` | ✅ |
| B-5 | 状態選択にアイコンを追加 | `presentation/post_creation_sheet.dart` | ⬜ |
| B-6 | 色選択をカラーパレットUIに変更 | `presentation/post_creation_sheet.dart` | ⬜ |

---

## Step C — 地図からシートを開けるようにする

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| C-1 | FAB を追加してボトムシートを開く | `web_map_screen.dart` | ✅ |

---

## Step D — 投稿の保存

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| D-1 | 画像を Supabase Storage にアップロード | `data/post_repository.dart` | ✅ |
| D-2 | 投稿を DB に INSERT | `data/post_repository.dart` | ✅ |
| D-3 | `submitPost()` を実装 | `presentation/post_creation_notifier.dart` | ✅ |
| D-4 | 投稿ボタンを `submitPost()` に接続 | `presentation/post_creation_sheet.dart` | ✅ |

---

## Step E — 地図にピン表示

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| E-1 | `FilterNotifier` を作成 | `presentation/filter_notifier.dart` | ✅ |
| E-2 | `fetchPosts()` にフィルタ条件を適用 | `data/post_repository.dart` | ✅ |
| E-3 | 投稿をピン/写真として地図に表示 | `web_map_screen.dart` | ✅ |
| E-4 | クラスタリング実装（広域:数字丸 / 中域:代表写真 / 拡大:全表示） | `web_map_screen.dart` | ⬜ 優先度低（後回し） |
| E-5 | 地図ピンを投稿時選択アイコンで表示 | `web_map_screen.dart` | ⬜ |
| E-6 | 地図表示を写真表示に切り替えられるようにする | `web_map_screen.dart` | ⬜ |

---

## Step F — タグ自動取得機能（仕様検討中・後回し）

> ⚠️ **仕様未確定のため実装保留。** `DESIGN.md` の「タグ自動取得機能」セクションを参照。

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| F-1 | Supabase Edge Function 作成（`functions/analyze-plant/`） | — | ⬜ 仕様確定後に着手 |
| F-2 | Step3 に「タグを自動取得」ボタンを追加 | `presentation/post_creation_sheet.dart` | ⬜ 仕様確定後に着手 |

---

## Step G — フィルタ UI パネル

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| G-1 | フィルタパネル Widget 作成（折りたたみ可能） | `presentation/filter_panel.dart` | ✅ |
| G-2 | カテゴリ選択（アイコン種別チェックボックス） | `presentation/filter_panel.dart` | ✅ |
| G-3 | 群生地のみ表示トグル | `presentation/filter_panel.dart` | ✅ |
| G-4 | 年フィルタ（FilterChip マルチ選択） | `presentation/filter_panel.dart` | ✅ |
| G-5 | 月日フィルタ（RangeSlider） | `presentation/filter_panel.dart` | ✅ |
| G-6 | フィルタパネルを地図画面に組み込む | `web_map_screen.dart` | ✅ |
| G-7 | 年・時期フィルタを地図上に常時表示（パネル折りたたみ時も見える） | `presentation/filter_panel.dart`, `web_map_screen.dart` | ⬜ |
| G-8 | 年を過去20年分に変更 | `presentation/filter_panel.dart` | ⬜ |
| G-9 | 色・状態・タグによるフィルタ追加 | `presentation/filter_panel.dart`, `presentation/filter_notifier.dart` | ⬜ |
| G-10 | 「適用」ボタンを追加し、ボタン押下後にフィルタ反映 | `presentation/filter_panel.dart`, `presentation/filter_notifier.dart` | ⬜ |

---

## Step H — 投稿詳細表示

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| H-1 | ピンタップで詳細ダイアログ/シートを表示 | `web_map_screen.dart` | ⬜ |
| H-2 | 詳細画面の UI 実装（写真・タグ・撮影日等） | `presentation/post_detail_sheet.dart` | ⬜ |

---

## Step I — いいね・お気に入り機能

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| I-1 | いいね機能（ログインユーザーのみ） | `data/post_repository.dart` | ⬜ |
| I-2 | お気に入りユーザー登録・フィルタ連携 | `data/post_repository.dart` | ⬜ |

---

## Step J — アカウント・認証機能

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| J-1 | Supabase Auth 連携（ログイン/サインアップ） | `presentation/auth_screen.dart` | ⬜ |
| J-2 | マイデータ絞り込み機能 | `presentation/filter_notifier.dart` | ⬜ |
| J-3 | 自分の投稿の編集・削除 | `data/post_repository.dart` | ⬜ |

---

## Step K — パフォーマンス改善

| # | タスク | ファイル | 状態 |
|---|---|---|---|
| K-1 | 地図拡大縮小時のフリーズ対策 | `web_map_screen.dart` | ✅ |
| K-2 | 起動時に地図を先に表示し、Supabaseのデータ取得後にマーカーを追加する（現状はデータ取得完了まで地図が出ない） | `web_map_screen.dart` | ✅ |

---

## 技術的負債

| # | 内容 | 優先度 |
|---|---|---|
| T-1 | `dart:io` の `File` を `XFile` に置き換え（Webでクラッシュする） | 高（Step B 前に対処） |
| T-2 | **リリース前に要対応**: `FilterState.defaultState()` の月日範囲をデバッグ用に全期間（1/1〜12/31）にしている。リリース前に「今日の前後15日間」に戻す（`domain/filter_state.dart`） | 高（リリース前） |
