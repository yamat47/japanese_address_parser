# Upstream Mapping — JS → Ruby 逐語移植対応表

移植元: **`@geolonia/normalize-japanese-addresses` v3.1.3**
commit: **`49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e`**
データ仕様: **`@geolonia/japanese-addresses-v2` v0.0.5**
配信 API 既定: `https://japanese-addresses-v2.geoloniamaps.com/api/ja`

> Ruby 各ファイルの先頭には、対応する JS ファイルの GitHub URL を上記 sha 付きでコメント記載すること（`docs/working_agreement.md` §3）。
> URL 雛形: `https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/<path>`

---

## 1. normalize ライブラリ本体（`src/` → `lib/japanese_address_parser/`）

| JS パス | 行数 | Ruby パス（案） | 主な公開要素 | 移植先 M |
| --- | ---: | --- | --- | --- |
| `src/normalize.ts` | 415 | `normalize.rb` | `normalize`（コア）, `normalizeTownName`, `normalizeAddrPart` | M5 / M8 |
| `src/config.ts` | 57 | `config.rb` | `currentConfig`, `defaultEndpoint`, `__internals.fetch` 相当 | M3 |
| `src/types.ts` | 157 | `normalize_result.rb` 他 | `NormalizeResult`, `NormalizeResultPoint`, `NormalizeResultMetadata`, `*ToResultPoint`, `upgradePoint` | M1 / M6 |
| `src/main-node.ts` | — | `fetcher.rb` | `requestHandlers.{file,http}`, `fetchOrReadFile`（HTTP/`file://` 分岐＋Range） | M3 |
| `src/lib/cacheRegexes.ts` | 450 | `cache_regexes.rb` | `getPrefectures`, `getPrefectureRegexPatterns`, `getCityRegexPatterns`, `getTownRegexPatterns`, `getSameNamedPrefectureCityRegexPatterns`, `getTowns`, `getRsdt`, `getChiban`, `fetchSubresource`, `parseSubresource` | M4（level3）/ M8（rsdt,chiban） |
| `src/lib/dict.ts` | 40 | `dict.rb` | `toRegexPattern` | M2 |
| `src/lib/kan2num.ts` | 16 | `kan2num.rb` | `kan2num` | M2 |
| `src/lib/zen2han.ts` | 5 | `zen2han.rb` | `zen2han` | M2 |
| `src/lib/patchAddr.ts` | 44 | `patch_addr.rb` | `patchAddr`（ハードコードされた 3 パッチ） | M2 |
| `src/lib/normalizeHelpers.ts` | 37 | `normalize_helpers.rb` | `prenormalize` | M2 |
| `src/lib/utils.ts` | 32 | `utils.rb` | `removeCitiesFromPrefecture`, `removeExtraFromMachiAza` | M2 |
| `src/lib/dictionaries/convert.ts` | 16 | `dictionaries/convert.rb` | `convert`（`dictionary` から正規表現生成） | M2 |
| `src/lib/dictionaries/dictionary.ts` | 9 | `dictionaries/dictionary.rb` | `dictionary`（辞書の集約） | M2 |
| `src/lib/dictionaries/jisDai2.ts` | 295 | `dictionaries/jis_dai2.rb` | `jisDai2Dictionary`（JIS第2水準 src/dst 対 — ほぼデータ） | M2 |
| `@geolonia/japanese-numeral`（外部 npm） | — | `japanese_numeral.rb` | `kanji2number`, `findKanjiNumbers`, `number2kanji` | M2 |
| `src/main.ts` / `src/cli.ts` | — | 不要 | ブラウザ/ES エントリ・CLI は Ruby では不要 | — |

---

## 2. データモデル（`@geolonia/japanese-addresses-v2` `src/data.ts` → `lib/japanese_address_parser/data/`）

すべて `Data.define` による immutable VO として移植。これが公開 VO（§3）の供給源になる。

| JS 型 | Ruby（案） | フィールド | ヘルパ |
| --- | --- | --- | --- |
| `SinglePrefecture` | `SinglePrefecture` | `code:Integer`, `pref`, `pref_k`, `pref_r`, `point:[lng,lat]`, `cities` | `prefectureName(pref) = pref.pref` |
| `SingleCity` | `SingleCity` | `code`, `county?`, `county_k?`, `county_r?`, `city`, `city_k`, `city_r`, `ward?`, `ward_k?`, `ward_r?`, `point` | `cityName(city) = "#{county}#{city}#{ward}"` |
| `SingleMachiAza` | `SingleMachiAza` | `machiaza_id`, `oaza_cho?`, `oaza_cho_k?`, `oaza_cho_r?`, `chome?`, `chome_n?:Integer`, `koaza?`, `koaza_k?`, `koaza_r?`, `rsdt?:true`, `point?`, `csv_ranges?` | `machiAzaName = "#{oaza_cho}#{chome}#{koaza}"` |
| `SingleRsdt` | `SingleRsdt` | `blk_num?`, `rsdt_num`, `rsdt_num2?`, `point?` | `rsdtToString = [blk_num,rsdt_num,rsdt_num2].compact.join('-')` |
| `SingleChiban` | `SingleChiban` | `prc_num1`, `prc_num2?`, `prc_num3?`, `point?` | `chibanToString = [prc_num1,prc_num2,prc_num3].compact.join('-')` |
| `Api<T>` | — | `meta: { updated:Integer }`, `data: T` | — |

`csv_ranges`: `{ "住居表示" => {start:, length:}, "地番" => {start:, length:} }` — `.txt` 内のバイトオフセット（M8 で使用）。

---

## 3. 配信 API エンドポイント（Fetcher が扱う）

| 用途 | パス | 形式 | 取得方法 |
| --- | --- | --- | --- |
| 全都道府県＋市区町村 | `/api/ja.json` | JSON（`PrefectureApi`） | 全体取得 |
| 町字（machiAza）一覧 | `/api/ja/{県}/{市}.json?v={updated}` | JSON（`MachiAzaApi`） | 全体取得 |
| 住居表示（rsdt） | `/api/ja/{県}/{市}-住居表示.txt?v={updated}` | CSV | **HTTP Range**（`csv_ranges.住居表示`） |
| 地番（chiban） | `/api/ja/{県}/{市}-地番.txt?v={updated}` | CSV | **HTTP Range**（`csv_ranges.地番`） |

- `meta.updated`（= `apiVersion`）をクエリ `?v=` に付けてキャッシュバスティングしている。
- HTTP: `Range: bytes={offset}-{offset+length-1}` ヘッダ。`file://`／ローカルパスでは該当バイトを seek して部分読みする（`src/main-node.ts` の `requestHandlers.file` に対応）。
- CSV パース（`parseSubresource`）: 先頭1行を捨て、残りを header 付き CSV としてパース。Ruby は標準 `csv`（`headers: true`）。

---

## 4. 公開 API（v3 `NormalizeResult` → Ruby VO）

詳細は `docs/rearchitecture.md` §5。対応の要点のみ:

| JS `NormalizeResult` | Ruby `Address`（案） | 備考 |
| --- | --- | --- |
| `pref`（string） | `prefecture: Prefecture`（リッチ VO） | `prefectureName` を `name` に、metadata の `SinglePrefecture` から `code`/`name_kana`/`name_romaji` 等 |
| `city`（string） | `city: City`（リッチ VO） | `cityName` を `name` に、`county`/`ward`/各カナ・ローマ字 |
| `town`（string） | `town: Town`（リッチ VO） | `machiAzaName` を `name` に、`machiaza_id`/`chome_n`/`point` 等 |
| `addr` | `addr` | 住居表示 or 地番の文字列（level 8） |
| `other` | `other` | 末尾の未正規化部 |
| `point: {lat,lng,level}` | `point`（または Town/Address 上の lat/lng） | §5 で確定する表現に従う |
| `level`（0/1/2/3/8） | `level` | |
| `metadata` | `metadata` | VO 未昇格分（rsdt/chiban の生データ等）の逃がし道 |
