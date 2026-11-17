# Alpine Plant Map — 設計書

## プロジェクト概要

地図上に高山植物の写真をマッピングし、開花・紅葉シーズンを可視化するモダンな登山支援アプリ。
1画面（シングルページ）構成で、美麗な地図表現と軽快なフィルタリング操作を両立させる。
基本的には、ウェブブラウザで表示を確認する。iOS、Androidは現時点では破綻しないようになっていれば良しとする。

## 技術スタック

- フロントエンド: Flutter (Dart)
- 状態管理・アーキテクチャ: MVVM（Riverpod + Notifier）※段階的に適用（下記）
- デザインシステム: Material Design Components (Material 3)
- 地図エンジン: Mapbox（モバイル: `mapbox_maps_flutter` / Web: `flutter_map` + Mapbox タイル）
- バックエンド・DB・ストレージ: Supabase (PostgreSQL + PostGIS拡張 / Supabase Storage)
- 環境変数: `--dart-define-from-file` + `String.fromEnvironment`（`.env` は Git に含めない）

## アーキテクチャ方針（MVVM + Riverpod）

勉強を兼ねて **MVVM（Riverpod + Notifier）** で進める。ただし **一気に全面適用せず、機能単位で段階的に導入** する。

### レイヤー分担

| 層 | 役割 | 例 |
|----|------|-----|
| **View** | `Widget`。表示とユーザー操作のみ | `MapScreen`, フィルタパネル |
| **Notifier** | 状態と操作への反応（ViewModel 相当） | `FilterNotifier`, `MapNotifier` |
| **Repository** | Supabase・地図データの取得・保存 | `PostRepository` |
| **Model** | 不変データクラス | `Post`, `FilterState` |

### コーディングルール

- View から Repository を **直接呼ばない**（Notifier 経由）
- 非同期データは `AsyncNotifier` / `AsyncValue` を検討
- 地図 Widget（Mapbox / flutter_map）のプラットフォーム差は **View 層** に閉じ込める（`web_map_screen` / `mobile_map_screen`）
- 地図の細かい描画ロジックを Notifier に詰め込みすぎない（Notifier はフィルタ・ピン一覧・選択状態など）

### フォルダ構成（目安）

```
lib/features/<機能名>/
  presentation/   # View, Notifier
  domain/         # Model
  data/           # Repository
```

### 導入の優先順位（予定）

1. 地図表示（現状のまま）
2. フィルタ → `FilterNotifier`
3. 投稿ダイアログ → 専用 Notifier
4. Supabase 連携 → Repository + `AsyncNotifier`

## 機能仕様

### 1. 地図表示機能

- Mapboxを全画面に描画し、投稿されたデータの緯度経度に従って投稿された画像 or アイコン（カスタムマーカー）を表示する。
- 地図上に「写真表示」と「アイコン表示」を切り替えるトグルボタンを配置する。
- アイコン表示時は、後述の「形状×色」をプログラム上で2色（ガク等のベース緑＋指定色）に重ね合わせたSVG、またはカスタムWidgetを描画する。
- 画像やアイコンの過度な密集を避けるため、広域ではクラスタリング（数字の丸）、中域では代表写真1枚、拡大したら全表示とする。

### 2. 投稿機能（ダイアログ形式）

- アカウントの有無を問わず投稿可能。
- 写真が選択・撮影された際、EXIFデータから「撮影位置（緯度経度）」と「撮影日時」をアプリ側で自動抽出し、DB保存時の初期値とする。
- 「撮影位置（緯度経度）」と「撮影日時」のない写真は、投稿させない。
- **テキストコメント機能は、モラル維持およびシンプルなUI構築のため「完全非推奨（実装しない）」とする。** 代わりに以下のメタデータをユーザーが選択して付加する。

#### 投稿時の選択項目

1. **アイコン（大項目×小項目×色）の選択**（大項目を選択後、小項目・色が動的に変化するUI）

   | 大項目 | 小項目 | 色 |
   |---|---|---|
   | 花 | つぼみ／五分咲き／満開／散り始め／終り | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 紅葉 | 序盤／8割／最盛期／終り | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 草木 | 草／木／巨木／苔／実 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 景色 | 山／滝／木道／雪原／雲／空／夜空／その他 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 山小屋 | 有人営業／無人利用可／利用不可／その他 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 食べ物 | 山小屋グルメ／自炊／その他 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 水場 | 枯れ／少ない／水あり | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 危険情報 | 崩落／通行不可／通行注意／雪渓 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | 野生動物 | サル／シカ／クマ／イノシシ／カモシカ／ライチョウ／ヘビ／タヌキ／キツネ／その他 | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |
   | その他 | なし | 赤／オレンジ／黄色／緑／水色／青／紫／茶色／白／黒／その他 |

2. **属性チェック**
   - **群生地マーク**: 複数株が密集している場合にオンにするトグル。

3. **タグ付け**
   - **植物名タグ**: カタカナまたは英語のみ。
   - **撮影場所（山岳名等）タグ**: 日本語または英語のみ。

### 3. フィルタ機能

- フィルタパネルはデフォルトで表示。地図全画面表示のために折りたたみ可能とする。

#### フィルタ条件

- **属性フィルタ**: 「群生地のみ表示」のON/OFF、および表示したいアイコン種別のチェックボックス切り替え。
- **撮影日（シーズン）フィルタ**:
  - **年（Year）**: `FilterChip` を用い、特定の年または「すべての年（デフォルト）」をマルチ選択。
  - **月日（MM-DD）**: `RangeSlider` でシーズン内の開始日・終了日を指定（例: 08/10〜08/20）。デフォルトは今日の前後15日間。年を跨いで同月日のデータを重ね合わせる（PostgreSQLの `TO_CHAR(shot_at, 'MM-DD')` を活用）。

### 4. 詳細表示

- アイコンや写真をタップすると、詳細情報を表示する。
- 詳細画面から「いいね！」を付加できる（ログインユーザーのみ）。
- 詳細画面から投稿をお気に入りにできる（ログインユーザーのみ）。

### 5. アカウント・認証機能（Supabase Auth連携）

#### ゲストユーザー（アカウントなし）
- 閲覧、および写真の新規投稿が可能。ただし、投稿後の編集・削除は不可。

#### ログインユーザー（アカウントあり）
- **マイデータ管理**: 自分が投稿したピンのみを地図上に絞り込む機能。
- **投稿編集・削除**: 自分の投稿の編集・削除が可能（SupabaseのRLSポリシーで制御）。
- **アカウント削除**: アカウント自体を削除できる。ただし過去の投稿データはコミュニティの資産としてマップ上に残す仕様とする。
- **いいね！機能**: 他者の投稿にワンタップで「いいね！」を付加できる（`likes` テーブルで管理）。
- **お気に入り（フォロー）機能**: 特定の投稿者をお気に入り登録し、フィルタバーから「お気に入りユーザーの投稿のみを表示」できる機能。

## IconCategory enum 定義

### 大項目（IconCategory）

| enum 値 | 表示名 |
|---|---|
| `flower` | 花 |
| `foliage` | 紅葉 |
| `vegetation` | 草木 |
| `scenery` | 景色 |
| `hut` | 山小屋 |
| `food` | 食べ物 |
| `water` | 水場 |
| `danger` | 危険情報 |
| `wildlife` | 野生動物 |
| `other` | その他 |

### 小項目（IconSubcategory）

| 大項目 | enum 値 | 表示名 |
|---|---|---|
| flower | `bud` | つぼみ |
| flower | `halfBloom` | 五分咲き |
| flower | `fullBloom` | 満開 |
| flower | `falling` | 散り始め |
| flower | `end` | 終り |
| foliage | `early` | 序盤 |
| foliage | `eighty` | 8割 |
| foliage | `peak` | 最盛期 |
| foliage | `end` | 終り |
| vegetation | `grass` | 草 |
| vegetation | `tree` | 木 |
| vegetation | `giantTree` | 巨木 |
| vegetation | `moss` | 苔 |
| vegetation | `berry` | 実 |
| scenery | `mountain` | 山 |
| scenery | `waterfall` | 滝 |
| scenery | `boardwalk` | 木道 |
| scenery | `snowfield` | 雪原 |
| scenery | `cloud` | 雲 |
| scenery | `sky` | 空 |
| scenery | `nightSky` | 夜空 |
| scenery | `other` | その他 |
| hut | `staffed` | 有人営業 |
| hut | `selfService` | 無人利用可 |
| hut | `closed` | 利用不可 |
| hut | `other` | その他 |
| food | `hutFood` | 山小屋グルメ |
| food | `selfCook` | 自炊 |
| food | `other` | その他 |
| water | `dry` | 枯れ |
| water | `low` | 少ない |
| water | `available` | 水あり |
| danger | `collapse` | 崩落 |
| danger | `closed` | 通行不可 |
| danger | `caution` | 通行注意 |
| danger | `snowSlope` | 雪渓 |
| wildlife | `monkey` | サル |
| wildlife | `deer` | シカ |
| wildlife | `bear` | クマ |
| wildlife | `boar` | イノシシ |
| wildlife | `serow` | カモシカ |
| wildlife | `ptarmigan` | ライチョウ |
| wildlife | `snake` | ヘビ |
| wildlife | `raccoonDog` | タヌキ |
| wildlife | `fox` | キツネ |
| wildlife | `other` | その他 |

### 色（IconColor）

| enum 値 | 表示名 |
|---|---|
| `red` | 赤 |
| `orange` | オレンジ |
| `yellow` | 黄色 |
| `green` | 緑 |
| `lightBlue` | 水色 |
| `blue` | 青 |
| `purple` | 紫 |
| `brown` | 茶色 |
| `white` | 白 |
| `black` | 黒 |
| `other` | その他 |

## タグ自動取得機能（仕様検討中）

> ⚠️ **実装保留中。** 以下の課題が未解決のため、仕様を固めてから着手する。

### 検討が必要な課題

#### 1. 取得方式の選定
以下の3つのアプローチを比較・選択する必要がある。

| 方式 | 内容 | 費用 | 懸念 |
|---|---|---|---|
| AI のみ | Google Cloud Vision API で画像からラベル取得 | 月1,000件まで無料 | 植物名の精度・日本語対応 |
| API のみ | 緯度経度 → 国土地理院 API で山名取得 | 無料 | 植物名は取れない |
| ハイブリッド | 画像 → Vision API（植物名）＋ 緯度経度 → リバースジオコーディング（山名） | 無料枠内 | 実装が複雑になる |

#### 2. タグ数・DB 負荷の設計
- タグは `plant_tags`（text[]）・`location_tags`（text[]）として posts テーブルに保存している。
- 自動取得でタグが膨大になると、Supabase 無料枠（個人開発）に対して検索・インデックスの負荷が懸念される。
- **検討ポイント:**
  - タグ数の上限をアプリ側で制限する（例: plantTags 最大5件）
  - タグの正規化（別テーブル化）を行うか、配列のまま維持するか
  - 全文検索インデックス（`GIN`）の必要性

#### 3. 実装場所
- APIキーをクライアントに持たせない場合 → Supabase Edge Functions（Deno/TypeScript）が必要
- 国土地理院 API のようにキー不要の公開 API → Flutter クライアントから直接呼び出し可能

### 仮のデータフロー（ハイブリッド案）
```
Flutter（写真選択 → 緯度経度・画像を取得）
  ├─ 画像 → Supabase Edge Function → Cloud Vision API → plantTags 候補
  └─ 緯度経度 → 国土地理院 API（クライアント直接） → locationTags 候補
  → 投稿ダイアログのタグ入力欄に自動セット（ユーザーが確認・編集して投稿）
```

### 着手条件
- 上記3点の仕様を決定してから実装を開始する。
- TODO.md の Step F を参照。
