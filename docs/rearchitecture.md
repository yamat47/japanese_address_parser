# Rearchitecture Design — v4.0.0

本ドキュメントは `japanese_address_parser` gem を v4.0.0 で大幅にリアーキテクトするための設計書である。
議論・合意した大方針と、実装フェーズで判断基準となる決定事項を集約する。
実装中に方針と矛盾する判断が必要になった場合は、先に本ドキュメントを更新してから進める（付録 A）。

> **関連ドキュメント**
> - `docs/working_agreement.md` — コンテキストクリア／`/goal` 駆動セッションの起点（運用ルール）
> - `docs/milestones.md` — 作業単位（M0〜M10）と完了条件
> - `docs/upstream_mapping.md` — JS → Ruby 逐語移植対応表

> **改訂履歴**: 初版は移植元を v2.10.0 と想定していたが、上流が **v3.1.3**（データモデルごと作り直したリライト）へ移行済みであることが判明したため、全面改訂した（2026-06）。

---

## 1. 目的

現在の gem は Node.js の JavaScript ライブラリ `@geolonia/normalize-japanese-addresses` に依存している。
Node ランタイムが無い環境では動作せず、`schmooze` 経由の橋渡しがデプロイ・CI・利用者のインストール体験に負担をかけている。

v4.0.0 では **Node.js 依存を完全に撤去**し、JavaScript ライブラリ（**v3.1.3**）の挙動を Ruby で逐語的に再実装する。

## 2. 大方針（合意済み）

| No. | 項目 | 決定 |
| --- | --- | --- |
| 1 | 仕様の起点 | `@geolonia/normalize-japanese-addresses` **v3.1.3**（commit `49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e`）を唯一の仕様として扱う。逐語的に Ruby へ翻訳し、ファイル・関数構成を揃える |
| 2 | スコープ | Node.js 依存を完全撤去。gem 単体で動作する（データは remote から取得） |
| 3 | 互換性ポリシー | JS の出力を完全再現する。正規表現も原則として文字列レベルで逐語コピー。差異はテストで検出し個別対応 |
| 4 | 追従の単位 | JS ライブラリのリリースに追従する。データリポジトリ（`japanese-addresses-v2`）の追従は不要（remote API として配信されるため）。なお v3.1.3 は Dec 2024 以降リリースが無く**実質フリーズ状態**で、追従コストは小さい |
| 5 | インターフェース | **v3 のみ対応**（`{ pref, city, town, addr, other, point, level, metadata }`）。level は 0/1/2/3/8 |
| 6 | データ配布 | **リモート既定**。`config` で差し替え可能（URL 文字列 or ローカルパス／`file://`）。gem にデータは同梱しない |
| 7 | 付加情報 | `code` / カナ / ローマ字 / 郡 / 政令区 等は **v3 データがネイティブに持つので提供する**（リッチ VO）。旧 gem のような独自付加情報 CSV は不要 |
| 8 | キャッシュ戦略 | JS と同じく、町丁目の正規表現パターンだけ LRU（`lru_redux`）。他は Hash で全件キャッシュ。**スレッド安全性は考慮しない**（JS 同様） |
| 9 | 並行性モデル | Ruby 側は**同期 API**に統一。JS の `async/await` は Ruby の慣習に合わせて blocking I/O へ落とす |
| 10 | リリース形態 | メジャーバージョンアップ（**v4.0.0**。gem は既に 3.2.0）で一気に切り替え。v2.x/v3.x からの後方互換性は維持しない。level 8 まで揃えて一括リリース |
| 11 | 公開 API の形 | `Data.define` による Value Object として、`Address#prefecture / #city / #town` のネストアクセスを維持。各 VO は v3 データでリッチ化 |
| 12 | 公開 API の挙動 | JS 忠実：`call` は**常に `Address`** を返す（未マッチは `level 0`）。**例外は fetch 失敗時のみ**（`call`→nil、`call!`→raise）。デフォルト `level=8`、毎呼び出し `level:` 公開 |

## 3. 全体アーキテクチャ

```
┌──────────────────────────────────────────────────┐
│ JapaneseAddressParser.call(address, level:) → Address │  ← 公開 API（常に Address / 未マッチ=level0）
└────────────────────────┬─────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────┐
│ Normalize.call(address, level:) → NormalizeResult │  ← JS normalize.ts の逐語翻訳
│   (pref, city, town, addr, other, point, level,   │
│    metadata)                                      │
└────────────────────────┬─────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────┐
│ CacheRegexes / Dict / Kan2num / PatchAddr /       │  ← JS src/lib/*.ts の逐語翻訳
│ Zen2han / NormalizeHelpers / Utils / Dictionaries │
│ / JapaneseNumeral                                 │
└────────────────────────┬─────────────────────────┘
                         │
┌────────────────────────▼─────────────────────────┐
│ Fetcher (HTTP / file)                             │  ← JS の __internals.fetch / main-node.ts 相当
│   JSON 全体取得 ＋ CSV の HTTP Range 部分取得      │
└────────────────────────┬─────────────────────────┘
                         │
                ┌────────▼────────┐
                │ Remote API      │  japanese-addresses-v2.geoloniamaps.com
                │ or file:// path │  /api/ja
                └─────────────────┘
```

## 4. モジュール構成（JS → Ruby マッピング）

物理的な `src/lib/` 二重化は避け、Ruby の `lib/japanese_address_parser/` 直下に配置する。
詳細な対応関係は `docs/upstream_mapping.md` を参照（行数・URL・移植先マイルストーン付き）。

各 Ruby ファイルの先頭には、元となる JS ファイルの GitHub URL を sha 付きでコメント記載する。

```ruby
# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/kan2num.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
```

主な対応（全量は `docs/upstream_mapping.md`）:

| JS パス | Ruby パス（案） | 備考 |
| --- | --- | --- |
| `src/normalize.ts` | `normalize.rb` | コア正規化ロジック（`normalizeTownName`/`normalizeAddrPart` 含む） |
| `src/config.ts` | `config.rb` | 設定 ＋ `__internals.fetch` 既定 |
| `src/types.ts` | `normalize_result.rb` 他 | `NormalizeResult` / `point` ヘルパ / `upgradePoint` |
| `src/main-node.ts` | `fetcher.rb` | HTTP / `file://` 分岐 ＋ Range |
| `src/lib/cacheRegexes.ts` | `cache_regexes.rb` | データ取得・キャッシュ・regex パターン・rsdt/chiban |
| `src/lib/dict.ts` | `dict.rb` | `toRegexPattern` |
| `src/lib/kan2num.ts` | `kan2num.rb` | 漢数字→アラビア数字 |
| `src/lib/zen2han.ts` | `zen2han.rb` | 全角英数→半角 |
| `src/lib/patchAddr.ts` | `patch_addr.rb` | 住所固有のパッチ |
| `src/lib/normalizeHelpers.ts` | `normalize_helpers.rb` | `prenormalize`（**v3 新規**） |
| `src/lib/utils.ts` | `utils.rb` | `removeCitiesFromPrefecture`/`removeExtraFromMachiAza`（**v3 新規**） |
| `src/lib/dictionaries/*.ts` | `dictionaries/*.rb` | `convert`/`dictionary`/`jisDai2`（**v3 新規**） |
| `@geolonia/japanese-numeral`（外部 npm） | `japanese_numeral.rb` | `number2kanji`/`kanji2number`/`findKanjiNumbers`。内製・単一モジュール |
| `@geolonia/japanese-addresses-v2` `src/data.ts` | `data/*.rb` | `Single*` 型 ＋ ヘルパ（**v3 新規・リッチ VO の供給源**） |
| `src/main.ts` / `src/cli.ts` | 不要 | ブラウザ/ES エントリ・CLI は Ruby では不要 |

## 5. 公開 API（v4.0.0）

### 5.1 エントリポイント

```ruby
JapaneseAddressParser.call(address_string, level: 8)   # → Address（fetch 失敗時のみ nil）
JapaneseAddressParser.call!(address_string, level: 8)  # → Address（fetch 失敗時は例外）
```

- **未マッチは失敗ではない**。都道府県すら判別できなくても `level 0` の `Address` を返す（JS 忠実）。
- `nil`／例外になるのは fetch（remote/file）失敗時のみ。
- デフォルト `level = 8`。毎呼び出しで `level:` を指定可能（JS の `option.level` 相当）。

### 5.2 Value Object（すべて `Data.define`／v3 データでリッチ化）

VO の `name` 系は JS のヘルパ（`prefectureName`/`cityName`/`machiAzaName`）に対応し、付加フィールドは
`metadata`（`SinglePrefecture`/`SingleCity`/`SingleMachiAza`）から供給する。最終的なフィールド集合は M1/M6 で確定する。想定:

```ruby
Address = Data.define(
  :full_address,  # 入力原文
  :prefecture,    # Prefecture（ネスト VO）
  :city,          # City（ネスト VO）
  :town,          # Town（ネスト VO）
  :addr,          # 住居表示 or 地番（level 8）
  :other,         # 末尾の未正規化部
  :point,         # 緯度経度＋その精度 level
  :level,         # 0 / 1 / 2 / 3 / 8
  :metadata       # VO 未昇格分（rsdt/chiban 生データ等）の逃がし道
)

Prefecture = Data.define(:name, :code, :name_kana, :name_romaji, :point)
City       = Data.define(:name, :code, :county, :ward, :name_kana, :name_romaji, :point)
Town       = Data.define(:name, :machiaza_id, :chome, :koaza, :point)
```

> 旧 v2.x の独自付加情報（別 CSV 由来の furigana 等）は廃止。ただし**情報自体は v3 データから供給するため、kana/romaji/code は復活する**（出所が変わる）。`point` は `{lat, lng, level}` の表現で持つ。

### 5.3 例外

既存の `JapaneseAddressParser::NormalizeError` は維持する。
fetch（remote/file）失敗時に `call!` から raise、`call` は nil を返す。
**未マッチ（level 0）は例外ではない**。

### 5.4 設定

```ruby
JapaneseAddressParser.configure do |c|
  c.japanese_addresses_api = 'https://japanese-addresses-v2.geoloniamaps.com/api/ja'  # デフォルト
  c.cache_size = 1_000
end
```

`japanese_addresses_api` の値で分岐：

- `http://` / `https://` で始まる → HTTP fetch
- `file://` で始まる、または絶対/相対パス → ローカルファイル読み込み

## 6. データアクセス層

### 6.1 Fetcher

JS の `__internals.fetch`（`src/main-node.ts` の `requestHandlers`）相当を `Fetcher` で提供する。**唯一の I/O 境界**。

```ruby
module JapaneseAddressParser
  module Fetcher
    # relative_path 例: '.json', '/東京都/渋谷区.json', '/東京都/渋谷区-住居表示.txt'
    # options: { offset:, length: } を渡すと Range 部分取得
    def self.call(relative_path, offset: nil, length: nil)
      case Config.japanese_addresses_api
      when %r{\Ahttps?://} then fetch_http(...)   # Net::HTTP（Range ヘッダ）
      else                      read_file(...)    # file:// / path（offset/length で seek）
      end
    end
  end
end
```

- HTTP: Ruby 標準の `Net::HTTP`。Range 指定時は `Range: bytes={offset}-{offset+length-1}`。外部 gem 依存を増やさない。
- ファイル: `file://` プレフィクスも素のパスも受け付ける。**Range 指定時は offset/length で部分読み**（level 8 の rsdt/chiban に必須。最初から実装する）。
- JSON 全体取得（`.json` 相当）と CSV テキスト取得（`.text` 相当）の両方をサポート。
- タイムアウト・リトライは最小限（JS 側も特別なリトライは無い）。CI のライブ CDN 依存対策としてのリトライは別途。

### 6.2 配信データの形式と取得方法

| 用途 | パス | 形式 | 取得 |
| --- | --- | --- | --- |
| 全県＋市区町村 | `/api/ja.json` | JSON | 全体 |
| 町字一覧 | `/api/ja/{県}/{市}.json?v={updated}` | JSON | 全体 |
| 住居表示（rsdt） | `/api/ja/{県}/{市}-住居表示.txt?v={updated}` | CSV | **HTTP Range**（`csv_ranges.住居表示`） |
| 地番（chiban） | `/api/ja/{県}/{市}-地番.txt?v={updated}` | CSV | **HTTP Range**（`csv_ranges.地番`） |

- `meta.updated`（= `apiVersion`）をクエリ `?v=` に付与してキャッシュバスティング。
- CSV パース（`parseSubresource`）: 先頭 1 行を捨て、残りを header 付き CSV としてパース。Ruby 標準 `csv`（`headers: true`）。

#### データ規模（実測・2026-06／全 1,898 市区町村）— 同梱しない根拠

| 層 | 1ファイル実測例 | 全国推計 |
| --- | --- | --- |
| `ja.json` | 314 KB | 314 KB |
| level 3 町字 JSON | 横浜港北 30KB / 京都中京 814KB | 概ね 50〜150 MB |
| level 8 rsdt+chiban CSV | 世田谷 rsdt 6.0MB / 世田谷 chiban 3.2MB | **数 GB（2〜6 GB 超）** |

level 8 を同梱すると数 GB となり gem として非現実的。level 3 のみ同梱（〜100MB）も肥大＋陳腐化（§2 No.4 と矛盾）。
→ **リモート既定・`file://` ミラーで補完**（§2 No.6）。

### 6.3 キャッシュ

JS と同じ方針。キャッシュはモジュール変数で保持（JS のモジュールスコープ変数に対応）。**スレッド安全性は考慮しない**（JS 同様。README に「スレッドセーフではない／起動時にキャッシュ暖機推奨」を明示）。

| 種類 | 実装 | 根拠 |
| --- | --- | --- |
| `cachedPrefectures` | 単純変数 | 一度取得したら不変 |
| `cachedPrefecturePatterns` | Hash | 生成後不変 |
| `cachedCityPatterns` | Hash（`pref` キー） | 47 都道府県分 |
| `cachedTowns` | Hash（`"pref-city"` キー） | データキャッシュ |
| `cachedTownRegexes` | **`LruRedux::Cache`**（既定 1000） | 1 市区町村あたり数百 regex。全件展開は重い |
| rsdt/chiban | Hash（`"kind-prefcode-citycode-town"` キー） | JS の `fetchFromCache` キーに対応（level 8） |

### 6.4 非同期性の落とし込み

JS の `async` 関数 → Ruby では同期関数。`await` → 素の呼び出し。`Promise.all` → 順次実行。

## 7. 依存関係（`gemspec` 変更）

### 追加
- `lru_redux`（ランタイム）

### 削除
- `schmooze`（ランタイム）

### 維持
- `csv`（rsdt/chiban の CSV パース、および標準ライブラリ切り出し対応）

### Ruby バージョン要件
- **`>= 3.2.0`** に引き上げる（`Data.define` 利用のため）
- CI マトリクスは 3.2, 3.3, 3.4

## 8. 型（RBS / Steep）

既存の `sig/japanese_address_parser.rbs` を全面刷新する（M9）。
`Steepfile` の strict 設定は維持。`sig/schmooze_base.rbs` は不要になるので削除。

## 9. テスト戦略

### 9.1 原則

JS のテストケースを Ruby に移植する。CI では JS を回さない。
**CI はライブ CDN を叩く**（JS 同様）。フィクスチャ drift で差異を見逃すリスクを避けるため、出力検証は実データに対して行う。
flaky／レート制限対策（リトライ・GH Actions キャッシュ）を入れる。`file://` は補助的に残す（filesystem-api テスト・ユーザ向け）。

座標（point）は**近似一致マッチャ**で比較する（JS の `toMatchCloseTo` 相当。データ更新の浮動小数ゆれ対策）。

### 9.2 取り込み対象（v3.1.3 `test/`）

| JS テスト | 方針 |
| --- | --- |
| `test/main/main.test.ts` | 全件移植。level 1/2/3/8 の基本ケース |
| `test/addresses/addresses.test.ts`（+`addresses.csv`） | 全件移植。大量住所の diff テスト。`addresses.csv` は `spec/fixtures/` にコピー |
| `test/main/filesystem-api.test.ts` | `file://` 経由のテストとして移植（必要ファイルを取得→ローカル参照） |
| `test/main/metadata.test.ts` | `metadata` 検証として移植 |

取り込み方針:
- 各ケースに元 JS ファイルの参照（sha）を記載
- RSpec のタグ `:upstream_port` を付与

### 9.3 Ruby 独自のテスト

- Ruby 固有 API（`Data` の `==`、`Address#to_h` など）
- **Onigmo vs V8** で挙動差が出たケース（発見都度追加）
- Config 分岐（HTTP / file）、Fetcher の Range 部分読み

## 10. アップストリーム追従運用

### 10.1 バージョン定数

`lib/japanese_address_parser/upstream.rb`：

```ruby
module JapaneseAddressParser
  UPSTREAM_NAME = '@geolonia/normalize-japanese-addresses'
  UPSTREAM_VERSION = '3.1.3'
  UPSTREAM_COMMIT_SHA = '49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e'
end
```

README 冒頭と CHANGELOG の各リリース記述にも同じ情報を明記する。

### 10.2 自動化

`.github/workflows/upstream-check.yml`（新規・M10）：

1. 週次 cron
2. `npm view @geolonia/normalize-japanese-addresses version` で最新取得
3. `UPSTREAM_VERSION` と比較
4. 差分があれば Issue 自動作成（新旧バージョン・compare リンク・変更ファイル↔Ruby 逆引き・翻訳チェックリスト）

> v3.1.3 は Dec 2024 以降リリースが無く実質フリーズ。低頻度監視で十分。

### 10.3 翻訳 PR のワークフロー

1. Issue の差分を確認
2. 変更された JS ファイルの先頭コメント URL を新 sha に差し替え
3. 差分を Ruby に逐語翻訳
4. JS の対応テストが追加・変更されていれば合わせて移植
5. `UPSTREAM_VERSION` / `UPSTREAM_COMMIT_SHA` を更新
6. CHANGELOG に追記

## 11. 移行パス（v3.x gem → v4.0.0）

### 11.1 削除されるもの
- `lib/japanese_address_parser/address_normalizer.rb` ＋ `address_normalizer/`（schmooze 層）
- `lib/japanese_address_parser/address_parser.rb`、`csv_parser.rb`
- `lib/japanese_address_parser/data/*.csv`（旧 1944 ファイル）
- `lib/japanese_address_parser/models/{prefecture,city,town,address}.rb`（現行実装）
- `js/` ディレクトリ一式
- `geolonia-japanese-addresses` submodule（`.gitmodules` ごと）
- `Rakefile` の `japanese_address_parser:parse_csv` タスク
- `Dockerfile` / `docker-compose.yml` の Node 関連
- `sig/schmooze_base.rbs`

### 11.2 追加されるもの
- JS 逐語翻訳の各ファイル（§4 / `docs/upstream_mapping.md`）
- `Data.define` による新 Value Object 群（リッチ VO ＋ Single* データモデル）
- `config.rb` / `fetcher.rb` / `upstream.rb`
- `.github/workflows/upstream-check.yml`
- `docs/upstream_mapping.md`、`docs/milestones.md`、`docs/working_agreement.md`（M0 で作成済み）

### 11.3 実装順序（マイルストーン）

詳細は `docs/milestones.md`。ハイレベル:

1. **M0** ドキュメント整備（本改訂含む）
2. **M1** データモデル層（japanese-addresses-v2 型）
3. **M2** ユーティリティ層
4. **M3** 設定 & データアクセス層
5. **M4** cacheRegexes（level 3 まで）
6. **M5** normalize 本体（level 0–3）
7. **M6** 公開 API & リッチ VO
8. **M7** テストスイート移植
9. **M8** level 8（rsdt / chiban）
10. **M9** 旧実装撤去 & 仕上げ
11. **M10** 追従自動化 & v4.0.0 リリース

## 12. 残っている小論点（実装時に確定する）

- **VO の最終フィールド集合**: §5.2 はドラフト。M1（Single* 型）と M6（公開 VO）で確定する。とくに `point` の表現（`Address#point` か `Town#latitude/longitude` か両方か）。
- **`csv` の標準ライブラリ依存**: 新しい Ruby では bundled gem 化が進むため gemspec に明示維持。
- **`UPSTREAM_COMMIT_SHA` の自動更新**: PR 作成時に人間が書き換える前提だが自動化の余地あり。
- **Onigmo 互換性**: 未知の挙動差がどれだけ出るか未検証。M2（dict/prenormalize/kan2num）と M5（normalize）で JS テストを流して実地検証。
- **CI のライブ CDN 依存**: レート制限・障害時の安定化（リトライ・キャッシュ・カナリア分離）を M7 で詰める。

---

## 付録 A: 決定を変えるときの手順

本ドキュメントの「大方針」を変える場合は：

1. 本ドキュメントの該当節を PR で更新
2. 変更理由を PR 本文に記載
3. 関連する実装変更を同じ PR または直後の PR で行う

実装中に「これは方針と衝突する」と気づいた場合は、勝手に実装で回避せず、まず本ドキュメントの更新を議論する。
コンテキストをクリアしたセッションは、まず `docs/working_agreement.md` を読むこと。
