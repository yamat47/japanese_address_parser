# Change Log
原則、JapaneseAddressParser に関する全ての変更はこのファイルに記載されます。

Change Log の形式は [Keep a Changelog](http://keepachangelog.com/) に従います。
またバージョンの付け方は [Semantic Versioning](https://semver.org/) に従います。

## [Unreleased]

### Added

### Changed

### Deprecated

### Removed

### Fixed

### Security

## [4.0.0]

Node.js / `schmooze` 依存を撤去し、[@geolonia/normalize-japanese-addresses](https://github.com/geolonia/normalize-japanese-addresses) **v3.1.3** を Ruby に逐語移植した大規模リアーキテクチャです。**v3.x との後方互換はありません。**

### Added

- 公開 API が正規化レベル（0/1/2/3/8）を返すようになりました。`level: 8` で住居表示（rsdt）・地番（chiban）まで解決します（既定は `8`、呼び出しごとに `level:` 指定可）。
- リッチな Value Object（`Address` / `Prefecture` / `City` / `Town`）。`code` / カナ / ローマ字 / 郡 / 政令区 / `machiaza_id` / `chome_n` / `point`（`lat`/`lng`/`level`）等を保持します。
- `point`（緯度経度＋精度レベル）と `metadata`（VO に昇格しない生データの逃がし道）を出力します。
- `file://`／ローカルパスのデータ源を第一級サポート（level 8 は Range 部分読み）。`JapaneseAddressParser.configure` で `japanese_addresses_api` / `cache_size` を設定できます。
- `JapaneseAddressParser::UPSTREAM_VERSION` / `UPSTREAM_COMMIT_SHA` 定数。

### Changed

- 住所データを **gem に同梱せず、配信 API から実行時に取得**するようになりました（既定はリモート）。**Node.js は不要**です。
- `call` は常に `Address` を返します（未マッチは `level 0` の `Address`）。`nil`／例外になるのは fetch 失敗時のみ（`call` は `nil`、`call!` は `NormalizeError`）。
- **スレッドセーフではありません**（上流同様）。起動時のキャッシュ暖機を推奨します。
- Ruby の必要バージョンを **>= 3.2.0** に更新しました。

### Removed

- Node.js / `schmooze` ブリッジ、同梱 CSV データ（1,943 ファイル）、旧 CSV ベースの Model と関連 API（`furigana` 等）を削除しました。

## [3.2.0]

### Changed

- [#105](https://github.com/yamat47/japanese_address_parser/pull/105) Update CI settings.([@yamat47](https://github.com/yamat47))
- [#103](https://github.com/yamat47/japanese_address_parser/pull/103) Bump @geolonia/normalize-japanese-addresses from 2.9.2 to 2.10.0 in /js([@yamat47](https://github.com/yamat47))
- [#104](https://github.com/yamat47/japanese_address_parser/pull/104) Bump geolonia-japanese-addresses from a8df8fe to 406bb43([@yamat47](https://github.com/yamat47))

### Fixed

- [#102](https://github.com/yamat47/japanese_address_parser/pull/102) #full_addressが処理前の住所の一部のみを返すようになっていた不具合を解消した。([@yamat47](https://github.com/yamat47))

## [3.1.2] - 2023-09-23

### Changed

- [#97](https://github.com/yamat47/japanese_address_parser/pull/97) parser gem のバージョンを最新の(3.2.2.3)にアップデートする([@takatea](https://github.com/takatea))

### Fixed

- [#99](https://github.com/yamat47/japanese_address_parser/pull/99) 最新のRuby（head）でCIを実行できるようにする

## [3.1.1] - 2023-09-07

### Changed

- [#95](https://github.com/yamat47/japanese_address_parser/pull/95) Bump @geolonia/normalize-japanese-addresses from 2.8.0 to 2.9.2 in /js([@yamat47](https://github.com/yamat47))

### Security

- [#94](https://github.com/yamat47/japanese_address_parser/pull/94) Bump activesupport from 7.0.4.3 to 7.0.7.1([@yamat47](https://github.com/yamat47))

## [3.1.0] - 2023-07-24

### Changed

- [#79](https://github.com/yamat47/japanese_address_parser/pull/79) Bump activesupport from 7.0.4 to 7.0.4.1([@yamat47](https://github.com/yamat47))
- [#84](https://github.com/yamat47/japanese_address_parser/pull/84) Bump activesupport from 7.0.4.1 to 7.0.4.3([@yamat47](https://github.com/yamat47))
- [#85](https://github.com/yamat47/japanese_address_parser/pull/85) CIに必要な権限を追加した。([@yamat47](https://github.com/yamat47))

### Removed

- [#89](https://github.com/yamat47/japanese_address_parser/pull/89) 最新のRubyでCIを実行するのを一時的に停止した。([@yamat47](https://github.com/yamat47))

## [3.0.5]
### Changed

- [#79](https://github.com/yamat47/japanese_address_parser/pull/79) Bump activesupport from 7.0.4 to 7.0.4.1([@yamat47](https://github.com/yamat47))

## [3.0.4] - 2023-01-14
### Added

- [#76](https://github.com/yamat47/japanese_address_parser/pull/76) CIで動作確認をするRubyのバージョンを増やした。([@yamat47](https://github.com/yamat47))

### Changed

- [#77](https://github.com/yamat47/japanese_address_parser/pull/77) Bump geolonia-japanese-addresses from ce956e6 to 662d645([@yamat47](https://github.com/yamat47))
- [#78](https://github.com/yamat47/japanese_address_parser/pull/78) Bump geolonia-japanese-addresses from 662d645 to eb3bc25([@yamat47](https://github.com/yamat47))

### Fixed

- [#75](https://github.com/yamat47/japanese_address_parser/pull/75) READMEのCIステータスバッジがリンク切れになっていたのを直した。([@yamat47](https://github.com/yamat47))

## [3.0.3] - 2022-12-28
### Added

- [#61](https://github.com/yamat47/japanese_address_parser/pull/61) Dependabotを使ってsubmodulesやnpmライブラリが自動で更新される仕組みを作った。([@yamat47](https://github.com/yamat47))
- [#64](https://github.com/yamat47/japanese_address_parser/pull/64) Dependabotがライブラリを更新するときに、それに依存しているソースコードも自動で更新されるようにした。([@yamat47](https://github.com/yamat47))
- [#65](https://github.com/yamat47/japanese_address_parser/pull/65) ソースコードの自動更新の仕組みを調整した。([@yamat47](https://github.com/yamat47))
- [#70](https://github.com/yamat47/japanese_address_parser/pull/70) CSVや内部で利用するライブラリの自動更新の仕組みを調整した。([@yamat47](https://github.com/yamat47))

### Changed

- [#72](https://github.com/yamat47/japanese_address_parser/pull/72) Bump geolonia-japanese-addresses from fa4822f to ce956e6([@yamat47](https://github.com/yamat47))
- [#73](https://github.com/yamat47/japanese_address_parser/pull/73) Bump @geolonia/normalize-japanese-addresses from 2.5.8 to 2.7.3 in /js([@yamat47](https://github.com/yamat47))

## [3.0.2] - 2022-11-19
### Changed

- [#59](https://github.com/yamat47/japanese_address_parser/pull/59) デモンストレーション環境のURLを更新した。([@yamat47](https://github.com/yamat47))

## [3.0.1] - 2022-09-25
### Added

- [#53](https://github.com/yamat47/japanese_address_parser/pull/53) Steepでの型検査の仕組みを導入した。([@yamat47](https://github.com/yamat47))

## [3.0.0] - 2022-09-25
### Added

- [#49](https://github.com/yamat47/japanese_address_parser/pull/49) Dockerを使って開発環境の準備をできるようにした。([@yamat47](https://github.com/yamat47))

### Security

- [#51](https://github.com/yamat47/japanese_address_parser/pull/51) Ruby 2.6 のサポートを切った。([@yamat47](https://github.com/yamat47))

## [2.2.1] - 2022-07-16
### Changed

- [#45](https://github.com/yamat47/japanese_address_parser/pull/45) geolonia/japanese-addressesのバージョンを上げた。([@yamat47](https://github.com/yamat47))
- [#46](https://github.com/yamat47/japanese_address_parser/pull/46) CIでRSpecを並列実行させるようにした。([@yamat47](https://github.com/yamat47))

## [2.2.0] - 2022-03-12
### Added

- [#44](https://github.com/yamat47/japanese_address_parser/pull/44) 住所の解析に失敗したときに例外を吐くモードと吐かないモードを使い分けられるようにした。([@yamat47](https://github.com/yamat47))

### Changed

- [#43](https://github.com/yamat47/japanese_address_parser/pull/43) 町丁目データを取得する処理の効率を上げた。([@yamat47](https://github.com/yamat47))

## [2.1.1] - 2022-03-06
### Changed

- [#41](https://github.com/yamat47/japanese_address_parser/pull/41) 利用しているライブラリのバージョンを上げた。([@yamat47](https://github.com/yamat47))

## [2.1.0] - 2022-02-05
### Changed

- [#38](https://github.com/yamat47/japanese_address_parser/pull/38) 住所の解析に失敗したときに発生する例外のクラスを`JapaneseAddressParser::NormalizeError`に固定した。([@yamat47](https://github.com/yamat47))

## [2.0.0] - 2022-01-31
### Added

- [#27](https://github.com/yamat47/japanese_address_parser/pull/27) 町域を探索するときに小字・通称名も使うようにした。([@yamat47](https://github.com/yamat47))
- [#30](https://github.com/yamat47/japanese_address_parser/pull/30) https://github.com/geolonia/normalize-japanese-addresses を使って住所を正規化する ([@champierre](https://github.com/champierre))

### Removed

- [#34](https://github.com/yamat47/japanese_address_parser/pull/34) 使わなくなったコード・依存関係を整理整頓した。([@yamat47](https://github.com/yamat47))

## [1.1.1] - 2022-01-08

### Fixed

- [#25](https://github.com/yamat47/japanese_address_parser/pull/25) 町域が含まれていないときに市区町村に含まれる最初の町域がヒットしてしまっていた不具合を解消した。([@yamat47](https://github.com/yamat47))

## [1.1.0] - 2022-01-07

### Changed

- [#23](https://github.com/yamat47/japanese_address_parser/pull/23) 町名を探索するときに前方一致を用いるのをやめた。([@yamat47](https://github.com/yamat47))

## [1.0.2] - 2022-01-06

### Changed

- [#21](https://github.com/yamat47/japanese_address_parser/pull/21) 利用しているデータをGitのSubmoduleとして取り入れるようにした。([@yamat47](https://github.com/yamat47))

## [1.0.1] - 2022-01-04

### Fixed

- [#17](https://github.com/yamat47/japanese_address_parser/pull/17) Gemとしてインストールすると使えなくなっていた不具合を解消した。([@yamat47](https://github.com/yamat47))

## [1.0.0] - 2022-01-04

- Initial release
