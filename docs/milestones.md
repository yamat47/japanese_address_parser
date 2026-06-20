# Milestones — v4.0.0 リアーキテクチャ

> **使い方**: 未チェック `[ ]` の最若番マイルストーンが次の作業。各マイルストーンの「完了条件(DoD)」をすべて満たしたらチェックを付け、同じ PR でこのファイルを更新する。
> 前提・ルールは `docs/working_agreement.md`、設計は `docs/rearchitecture.md`、移植対応は `docs/upstream_mapping.md`。

## 進捗

- [x] **M0** 設計確定（ドキュメント整備）
- [ ] **M1** データモデル層（japanese-addresses-v2 型）
- [ ] **M2** ユーティリティ層
- [ ] **M3** 設定 & データアクセス層（config / fetcher）
- [ ] **M4** cacheRegexes（level 3 まで）
- [ ] **M5** normalize 本体（level 0–3）
- [ ] **M6** 公開 API & リッチ VO
- [ ] **M7** テストスイート移植
- [ ] **M8** level 8（rsdt / chiban）
- [ ] **M9** 旧実装撤去 & 仕上げ
- [ ] **M10** アップストリーム追従自動化 & リリース

---

## 依存関係

```
M0 → M1 → M2 ─┐
              ├→ M4 → M5 → M6 → M7 → M8 → M9 → M10
M1 ─→ M3 ─────┘
```

- M2（utils）と M3（config/fetcher）は M1（データモデル）が前提。互いには独立。
- M4（cacheRegexes）は M1・M2・M3 すべてに依存。
- M8（level 8）は M4〜M7 が揃ってから。データアクセス層（M3）と VO（M6）は M1 の時点で level 8 を見据えた形にしておく（後付け禁止）。

---

## M0 — 設計確定（ドキュメント整備）

**スコープ**: v2 前提だった旧設計を v3.1.3 前提に改訂し、コンテキストクリア／`/goal` 駆動でも単独着手できるドキュメント基盤を整える。

- `docs/rearchitecture.md` を v3.1.3 決定に改訂
- `docs/milestones.md`（本ファイル）新規
- `docs/upstream_mapping.md` 新規
- `docs/working_agreement.md` 新規
- `CLAUDE.md` に working_agreement への数行ポインタ追記
- `rearchitecture` ブランチ作成

**DoD**: 4 ドキュメント＋CLAUDE.md ポインタが存在し、確定方針（working_agreement §1）と矛盾しない。コードは変更しない。

---

## M1 — データモデル層

**移植元**: `@geolonia/japanese-addresses-v2` `src/data.ts`（型＋ヘルパ）。
**Ruby**: `lib/japanese_address_parser/data/*.rb`（`docs/upstream_mapping.md` §2）。

**スコープ**:
- `SinglePrefecture` / `SingleCity` / `SingleMachiAza` / `SingleRsdt` / `SingleChiban` を `Data.define` で実装。
- ヘルパ `prefecture_name` / `city_name`（郡＋市＋政令区）/ `machi_aza_name`（大字＋丁目＋小字）/ `rsdt_to_string` / `chiban_to_string`。
- JSON（Hash）→ VO の変換（`from_json` 相当）。**level 8 を見据え、`csv_ranges` も保持する**。

**DoD**:
- 各型・ヘルパの RSpec（実データの一部を fixture にして変換と文字列生成を検証）。
- カナ・ローマ字・code・point・郡・政令区を保持できている（リッチ VO の供給源）。
- `rubocop` / `steep` green。

---

## M2 — ユーティリティ層

**移植元**: `src/lib/{zen2han,kan2num,dict,patchAddr,normalizeHelpers,utils}.ts`, `src/lib/dictionaries/{convert,dictionary,jisDai2}.ts`, 外部 `@geolonia/japanese-numeral`。

**スコープ（1 ファイル ≒ 1 PR）**:
- `zen2han`（全角英数→半角）
- `japanese_numeral`（`kanji2number` / `find_kanji_numbers` / `number2kanji` を内製、単一モジュール）
- `kan2num`（`find_kanji_numbers` → `kanji2number` 置換）
- `dictionaries/jis_dai2`（JIS第2水準辞書データ）→ `dictionaries/dictionary` → `dictionaries/convert`
- `dict`（`to_regex_pattern`）
- `patch_addr`（3 パッチ）
- `normalize_helpers`（`prenormalize`）
- `utils`（`remove_cities_from_prefecture` / `remove_extra_from_machi_aza`）

**DoD**:
- **正規表現は逐語コピー**（working_agreement §3）。各ファイル先頭に upstream URL+sha。
- 各モジュールの RSpec。とくに `dict`・`prenormalize`・`kan2num` は JS↔Onigmo 差異の初期検出ポイントなので、代表入力で JS と同値になることを確認。
- `rubocop` / `steep` green。

---

## M3 — 設定 & データアクセス層

**移植元**: `src/config.ts`, `src/main-node.ts`（`requestHandlers` / `fetchOrReadFile`）。

**スコープ**:
- `config`: `japanese_addresses_api`（既定 `https://japanese-addresses-v2.geoloniamaps.com/api/ja`）、`cache_size`（既定 1000）、`configure` ブロック。
- `fetcher`（`__internals.fetch` 相当・唯一の I/O 境界）:
  - `http://` / `https://` → `Net::HTTP`。Range 指定時は `Range: bytes=...` ヘッダ。
  - `file://` ／ローカルパス → ファイル読み。**Range 指定時は offset/length で seek して部分読み**（level 8 前提で最初から実装）。
  - JSON 取得（`.json()` 相当）と CSV テキスト取得（`.text()` 相当）の両方を返せる。

**DoD**:
- HTTP モード: WebMock で URL 組み立て・`Range` ヘッダ・JSON/CSV パースをユニット検証（実通信なし）。
- file モード: fixture に対する全体読み＋Range 部分読みを検証。
- `rubocop` / `steep` green。

---

## M4 — cacheRegexes（level 3 まで）

**移植元**: `src/lib/cacheRegexes.ts`（rsdt/chiban を除く部分）。

**スコープ**:
- `get_prefectures`（`ja.json`）, `get_prefecture_regex_patterns`, `get_city_regex_patterns`, `get_same_named_prefecture_city_regex_patterns`, `get_towns`（`/{県}/{市}.json`）, `get_town_regex_patterns`（`to_regex_pattern` 利用）。
- キャッシュ: `cachedPrefectures` 等は単純 Hash、`cachedTownRegexes` は **`LruRedux::Cache`**（既定 1000）。**スレッド安全性は考慮しない**（working_agreement §1-6）。
- `get_rsdt` / `get_chiban` は**枠（メソッド定義）だけ用意**し、本実装は M8。

**DoD**:
- ライブ CDN または fixture に対する RSpec（都道府県・市・町字パターンが生成され、代表住所がマッチ）。
- LRU が既定サイズで動作。
- `rubocop` / `steep` green。

---

## M5 — normalize 本体（level 0–3）

**移植元**: `src/normalize.ts`（`option.level <= 3` の早期 return まで）。

**スコープ**:
- `prenormalize` → 都道府県 → 市区町村 → 町字 の逐語移植。
- 県名省略・同名県市（例: 千葉県千葉市・府中市）の分岐、町丁目以降の番地正規化（`replace` チェーン逐語コピー）。
- `patch_addr` 適用、`level` 計算、`option.level <= 3 || level < 3` での早期 return（rsdt/chiban フェッチなし）。
- 返すのは内部 `NormalizeResult` 相当（公開 VO 化は M6）。

**DoD**:
- `level` 1/2/3 の代表ケース（例: `神奈川県横浜市港北区大豆戸町１７番地１１`）が JS と同値。
- ライブ CDN を叩く RSpec（`:upstream_port` タグ）。座標は近似一致マッチャ。
- `rubocop` / `steep` green。

---

## M6 — 公開 API & リッチ VO

**スコープ**:
- `JapaneseAddressParser.call(address, level: 8)` / `.call!(...)`（working_agreement §1-7 のセマンティクス: 常に `Address`、未マッチ=level0、例外は fetch 失敗のみ）。
- リッチ VO: `Address` / `Prefecture` / `City` / `Town`（`Data.define`）。M1 の Single* から `code`/カナ/ローマ字/郡/政令区/`machiaza_id`/`point` 等を反映。
- `metadata` 逃がし道（VO 未昇格分）。`Address#to_h` 等の Ruby 独自 API。
- `NormalizeError` 維持。

**DoD**:
- 公開 API の RSpec（VO の `==` 値比較、`to_h`、未マッチ=level0、fetch 失敗時の nil/raise）。
- RBS を新 VO に合わせて整備（最終刷新は M9）。
- `rubocop` / `steep` green。

---

## M7 — テストスイート移植

**移植元**: `test/main/main.test.ts`, `test/addresses/addresses.test.ts`（+`addresses.csv`）, `test/main/filesystem-api.test.ts`, `test/main/metadata.test.ts`。

**スコープ**:
- `addresses.csv` を `spec/fixtures/` にコピーし、全件 diff テストを RSpec 化。
- 基本ケース・filesystem(`file://`)ケース・metadata ケースを移植。
- **CI はライブ CDN を叩く**。flaky/レート制限対策（リトライ、GH Actions キャッシュ）。
- 座標用の近似一致マッチャ実装。`:upstream_port` タグ運用。

**DoD**:
- 全移植ケース green（level 8 が必要なケースは M8 後に有効化、または `pending`）。
- CI ワークフローがネットワーク egress 前提で安定動作。

---

## M8 — level 8（rsdt / chiban）

**移植元**: `src/normalize.ts`（`normalizeAddrPart` 以降）, `src/lib/cacheRegexes.ts`（`getRsdt`/`getChiban`/`fetchSubresource`/`parseSubresource`）。

**スコープ**:
- `fetch_subresource`（`-住居表示.txt`/`-地番.txt` を Range 取得）, `parse_subresource`（先頭行除去＋CSV）。
- `normalize_addr_part`（番地マッチ→rsdt or chiban 解決、rsdt 優先の TODO 挙動も踏襲）。
- `addr` / `point`(level8) / `metadata.rsdt`/`metadata.chiban` を結果に反映。VO に `addr` 等を反映。

**DoD**:
- level 8 ケース（例: `渋谷区道玄坂1-10-8` → town `道玄坂一丁目`, level 8）が JS と同値。
- M7 で pending にしていた level 8 ケースを有効化し green。
- `rubocop` / `steep` green。

---

## M9 — 旧実装撤去 & 仕上げ

**スコープ（削除）**:
- `lib/japanese_address_parser/address_normalizer.rb` ＋ `address_normalizer/`（schmooze 層）
- `lib/japanese_address_parser/address_parser.rb`, `csv_parser.rb`
- `lib/japanese_address_parser/data/*.csv`（旧 1944 ファイル）
- `lib/japanese_address_parser/models/{prefecture,city,town,address}.rb`（旧実装）
- `js/` 一式、`geolonia-japanese-addresses` submodule、`.gitmodules`
- `Rakefile` の `japanese_address_parser:parse_csv`、`Dockerfile`/`docker-compose.yml` の Node 関連
- `sig/schmooze_base.rbs`

**スコープ（調整）**:
- `gemspec`: `lru_redux` 追加 / `schmooze` 削除 / `csv` 維持 / `required_ruby_version >= 3.2.0`。
- RBS 全面刷新（`sig/japanese_address_parser.rbs`）、`Steepfile` strict 維持。
- README 刷新（リモート既定・スレッド非安全・`file://`・UPSTREAM 情報）。
- `lib/japanese_address_parser/upstream.rb`（`UPSTREAM_VERSION='3.1.3'`, `UPSTREAM_COMMIT_SHA`）。

**DoD**:
- 旧コード参照ゼロ。`bundle exec rake` green。schmooze なしで全テスト green。
- CI マトリクスを 3.2 / 3.3 / 3.4 に整理。

---

## M10 — アップストリーム追従自動化 & リリース

**スコープ**:
- `.github/workflows/upstream-check.yml`: 週次 cron で `npm view @geolonia/normalize-japanese-addresses version` を取得し `UPSTREAM_VERSION` と比較、差分あれば Issue 自動作成（compare リンク・変更ファイル↔Ruby 逆引き・翻訳チェックリスト）。
  - 注: v3.1.3 は Dec 2024 以降リリースが無く実質フリーズ。低頻度で十分。
- `version.rb` を `4.0.0` に。CHANGELOG 追記。
- `rearchitecture → main` の最終 PR で v4.0.0 リリース。

**DoD**:
- upstream-check workflow が動作（dry-run 確認）。
- CHANGELOG / README / UPSTREAM 定数が整合。
- v4.0.0 タグ。
