# Change Log
原則、JapaneseAddressParser に関する全ての変更はこのファイルに記載されます。

Change Log の形式は [Keep a Changelog](http://keepachangelog.com/) に従います。
またバージョンの付け方は [Semantic Versioning](https://semver.org/) に従います。

## [Unreleased]
### Added

- [#44](https://github.com/yamat47/japanese_address_parser/pull/44) 住所の解析に失敗したときに例外を吐くモードと吐かないモードを使い分けられるようにした。([@yamat47](https://github.com/yamat47))

### Changed

- [#43](https://github.com/yamat47/japanese_address_parser/pull/43) 町丁目データを取得する処理の効率を上げた。([@yamat47](https://github.com/yamat47))

### Deprecated

### Removed

### Fixed

### Security

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
