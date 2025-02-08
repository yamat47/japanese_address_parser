# Change Log
原則、JapaneseAddressParser に関する全ての変更はこのファイルに記載されます。

Change Log の形式は [Keep a Changelog](http://keepachangelog.com/) に従います。
またバージョンの付け方は [Semantic Versioning](https://semver.org/) に従います。

## [Unreleased]

### Added
- [#109](https://github.com/yamat47/japanese_address_parser/pull/109) READMEにDocker composeを利用した際の使い方を追記([@tossyi](https://github.com/tossyi))

- [#108](https://github.com/yamat47/japanese_address_parser/pull/108) Add csv to gemspec for new Ruby versions ([@balvig](https://github.com/balvig))

### Changed

### Deprecated

### Removed

### Fixed

### Security

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
