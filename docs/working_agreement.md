# Working Agreement — v4.0.0 リアーキテクチャ

> **このドキュメントは、コンテキストをクリアした新規セッション（`/goal` 駆動を含む）が最初に読むエントリポイントである。**
> ここを起点に `docs/rearchitecture.md`（設計の真実源）、`docs/milestones.md`（作業単位）、`docs/upstream_mapping.md`（逐語移植対応表）へ辿る。

---

## 0. まず把握すること（30秒サマリ）

`japanese_address_parser` gem を **v4.0.0 で大幅リアーキテクト**している。

- **目的**: Node.js / `schmooze` 依存を完全撤去し、`@geolonia/normalize-japanese-addresses` **v3.1.3** を Ruby に逐語移植する。
- **作業ブランチ**: `rearchitecture`（長命ブランチ）。各マイルストーンを**個別PRで `rearchitecture` 宛て**に積む。最後に `rearchitecture → main` の単一PRで v4.0.0 をリリース。
- **現在地の確認方法**: `docs/milestones.md` のチェックボックスを見る。**未チェックの最若番マイルストーンが次の作業**。
- **設計判断で迷ったら**: `docs/rearchitecture.md` を読む。そこに無い判断が必要なら、**勝手に決めず利用者に質問する**（§5 参照）。

---

## 1. 確定済みの大方針（再議論しない）

以下はオーナーとの議論で**確定済み**。実装中にこれらと矛盾する判断が要るときは、勝手に回避せず、まず `docs/rearchitecture.md` を更新する議論をする（§5）。

| # | 決定 |
| --- | --- |
| 1 | 移植対象は **v3.1.3**（commit `49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e`）。v2 系は移植しない。 |
| 2 | **level 8（住居表示 rsdt / 地番 chiban）まで完全移植**する。ただし実装順序としては level 8 を**最終マイルストーン**に回す。**データアクセス層・VO・キャッシュ・モジュール境界は最初から level 8 前提で設計する**（後付けの付け焼き刃は禁止）。 |
| 3 | 公開 VO は **v3 データでリッチ化**する（`code` / カナ / ローマ字 / 郡 / 政令区 / `machiaza_id` / `point` 等）。これらは v3 データがネイティブに持つので提供する。VO に昇格しない情報（rsdt/chiban の生データ等）は raw `metadata` で逃がす。 |
| 4 | 出力は JS v3 を忠実再現：`point: {lat, lng, level}`（ネスト）＋ `metadata` ＋ `level` は 0/1/2/3/8。 |
| 5 | データ源は **リモート既定**（`https://japanese-addresses-v2.geoloniamaps.com/api/ja`）。**gem にデータは同梱しない**（level3 で〜100MB、level8 で数GBのため非現実的）。`file://` ／ローカルパス＋**Range 部分読み**を第一級サポートする。 |
| 6 | **スレッド安全性は JS 同様考慮しない**。README に「スレッドセーフではない／起動時にキャッシュ暖機推奨」を明示する。 |
| 7 | 公開 API は **JS 忠実**：`call` は**常に `Address` を返す**（未マッチは `level 0` の `Address`）。**例外は fetch 失敗時のみ**（`call` は nil、`call!` は raise）。デフォルト `level = 8`、毎呼び出しの `level:` オプションを公開。 |
| 8 | **テストは JS 同様ライブ CDN を CI で叩く**。座標は近似一致マッチャで比較。アップストリーム由来ケースは `:upstream_port` タグを付ける。`file://` は補助的に残す（filesystem-api テスト移植・ユーザ向け）。 |
| 9 | HTTP は **`Net::HTTP`**（Range 対応・依存を増やさない）。`japanese-numeral` は**内製モジュール**化（将来 gem 化に備え単一化）。Ruby **>= 3.2**（`Data.define`）。 |
| 10 | バージョンは **v4.0.0**（gem は既に 3.2.0 のため v3.0.0 は使えない）。v2.x 後方互換は維持しない。 |

---

## 2. ブランチ・PR 運用

- すべての作業 PR は **base = `rearchitecture`**。`main` には直接入れない。
- **1 マイルストーン ≒ 1〜数 PR**。レビュー可能な粒度に保つ（目安: 1 つの移植元ファイル＋その spec で 1 PR）。
- **旧 schmooze 実装は M9 まで温存する**。新コードは旧コードと並存させ、`rearchitecture` ブランチが常に green／動作する状態を保つ。M5〜M8 では新旧の出力を突き合わせられる。
- 各 PR は**自分の RSpec で green**にする（モジュール単位でテストするので、全体統合前でも CI は green を保てる）。
- **中間リリースはしない**。`rearchitecture → main` の最終 PR で v4.0.0 を一括リリース。
- コミットメッセージ末尾の Co-Authored-By 等、リポジトリの規約に従う。**コミット・プッシュはオーナーの指示があるときだけ**行う。

---

## 3. 逐語移植のルール（fidelity）

設計書 §3 の「完全再現」を厳守する。

1. **正規表現は文字列レベルで逐語コピー**する。「Ruby らしく」書き換えない。JS の `String.prototype.replace` チェーンは順序も含めてそのまま移す。
2. **上流ロジックを"改善"しない**。TODO コメントやバグに見える挙動もそのまま移植する（差異はテストで検出して個別対応する）。
3. 各 Ruby ファイルの**先頭に移植元 JS の GitHub URL を sha 付きでコメント記載**する。例:
   ```ruby
   # Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/kan2num.ts
   # Upstream: @geolonia/normalize-japanese-addresses v3.1.3
   ```
4. **JS↔Onigmo の正規表現差異**に注意する（`\d` の Unicode 解釈、名前付きグループ、フラグ、サロゲート等）。差異を見つけたら spec に Ruby 独自ケースとして残す（設計書 §9.3）。
5. ファイル・関数構成は JS に揃える（`docs/upstream_mapping.md` の対応表に従う）。

---

## 4. 上流コードの読み方

移植元は GitHub に置かれている。`gh` CLI で取得する（ローカルに submodule は置かない）。

```bash
SHA=49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e

# 1ファイルを読む
gh api "repos/geolonia/normalize-japanese-addresses/contents/src/lib/kan2num.ts?ref=$SHA" --jq '.content' | base64 -d

# src ツリー一覧
gh api "repos/geolonia/normalize-japanese-addresses/git/trees/$SHA?recursive=1" --jq '.tree[].path' | grep '^src/'

# データ仕様（型・ヘルパ）は japanese-addresses-v2 リポジトリの src/data.ts
gh api "repos/geolonia/japanese-addresses-v2/contents/src/data.ts" --jq '.content' | base64 -d
```

配信 API の実データを確認する（CI もここを叩く）:

```bash
BASE="https://japanese-addresses-v2.geoloniamaps.com/api/ja"
curl -s "$BASE.json"                       # 全都道府県+市区町村
curl -s "$BASE/東京都/渋谷区.json"          # 町字（machiAza）
curl -sr 0-200 "$BASE/東京都/渋谷区-住居表示.txt"  # rsdt（Range 部分取得; CSV）
```

---

## 5. 質問の原則

- **設計書（rearchitecture.md）に答えがある問いは、質問せずドキュメントに従う。**
- **コードベース／上流を調べれば分かる問いは、調べて答える。**
- それでも決められない仕様・要件（挙動の解釈、新たなトレードオフ、方針との衝突）は、**勝手に決めずオーナーに質問する**。判断を変える場合は設計書 §12 / 付録 A の手順（まずドキュメントを PR で更新）に従う。

---

## 6. 検証コマンド（DoD 共通）

各 PR / マイルストーン完了時に最低限これを通す:

```bash
bundle exec rspec      # テスト（移植ケースは :upstream_port タグ）
bundle exec rubocop    # Lint
bundle exec steep check # 型
bundle exec rake       # まとめ（RSpec + RuboCop）
```

各マイルストーン固有の完了条件（DoD）は `docs/milestones.md` を参照。
