![CI Status](https://github.com/yamat47/japanese_address_parser/actions/workflows/main.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/japanese_address_parser.svg)](https://badge.fury.io/rb/japanese_address_parser)

# JapaneseAddressParser
JapaneseAddressParser は日本の住所をパースすることができる Ruby gem です。

住所のパースに使っているのは [geolonia/normalize-japanese-addresses](https://github.com/geolonia/normalize-japanese-addresses) です。
npm のライブラリを Ruby のランタイムから呼び出しているため、Node が実行できる環境でしか動作しません。

こちらのページで機能を試すことができます：[デモンストレーション | JapaneseAddressParser](https://japanese-address-parser-demo.herokuapp.com/)

## インストール

`Gemfile` にこの行を追加してください：

```ruby
gem 'japanese_address_parser'
```

次にこのコマンドを実行してください：

```
$ bundle install
```

もしくは gem install をして直接インストールすることもできます：

```
$ gem install japanese_address_parser
```

## 使い方
```ruby
address = JapaneseAddressParser.call('東京都港区芝公園4-2-8')

address.class #=> JapaneseAddressParser::Models::Address

prefecture = address.prefecture
prefecture.attributes #=> {:code=>"13", :name=>"東京都", :name_kana=>"トウキョウト", :name_romaji=>"TOKYO TO"}

city = address.city
city.attributes #=> {:code=>"13103", :formatted_code=>"13103", :prefecture_code=>"13", :name=>"港区", :name_kana=>"ミナトク", :name_romaji=>"MINATO KU"}

town = address.town
town.attributes #=> {:name=>"芝公園四丁目", :name_kana=>"シバコウエン 4", :name_romaji=>"SHIBAKOEN 4", :nickname=>nil, :latitude=>"35.656459", :longitude=>"139.74764"}

address.full_address #=> "東京都港区芝公園4-2-8"
address.furigana #=> "トウキョウトミナトクシバコウエン 4"
```

<details>
<summary>都道府県データの属性</summary>

クラス：`JapaneseAddressParser::Models::Prefecture`

| 属性 | 説明 | 例 |
| --- | --- | --- |
| `code` | 都道府県コード | `"01"` |
| `name` | 名前 | `"北海道"` |
| `name_kana` | ふりがな | `"ホッカイドウ"` |
| `name_romaji` | ローマ字 | `"HOKKAIDO"` |
</details>

<details>
<summary>市区町村データの属性</summary>

クラス：`JapaneseAddressParser::Models::City`

| 属性 | 説明 | 例 |
| --- | --- | --- |
| `code` | 市区町村コード | `"01101"` |
| `formatted_code` | 整形された市区町村コード<br>市区町村コードがない場合に `"UNKNOWN"` が入っています。 | `"01101"` / `"UNKNOWN"` |
| `prefecture_code` | 都道府県コード | `"01"` |
| `name` | 名前 | `"札幌市中央区"` |
| `name_kana` | ふりがな | `"サッポロシチュウオウク"` |
| `name_romaji` | ローマ字 | `"SAPPORO SHI CHUO KU"` |
</details>

<details>
<summary>町域データの属性</summary>

クラス：`JapaneseAddressParser::Models::Town`

| 属性 | 説明 | 例 |
| --- | --- | --- |
| `name` | 名前 | `"旭ケ丘一丁目"` |
| `name_kana` | ふりがな | `"アサヒガオカ 1"` |
| `name_romaji` | ローマ字 | `"ASAHIGAOKA 1"` |
| `nickname` | 小字・通称名 |  |
| `latitude` | 緯度 | `"43.04223"` |
| `longitude` | 経度 | `"141.319722"` |
</details>

都道府県や市区町村、町域のそれぞれの属性の値は [geolonia/japanese-addresses](https://github.com/geolonia/japanese-addresses) が提供している CSV ファイルの値そのままです。

何らかの理由で住所の解析に失敗したときは `JapaneseAddressParser::NormalizeError` を `raise` します。

## 開発
開発に必要なライブラリをインストールするには、このコマンドを実行してください：

```
bin/setup
```

自動テストやリンターを実行するには、このコマンドを実行してください：

```
rake
```

## 貢献方法
イシューやプルリクエストは随時お待ちしています。

特に住所の正規化については漏れているケースがまだまだ数多くありそうです。
「この住所だとうまくパースできないよ」くらいの気軽なもので結構ですので、イシューでのご報告をお願いします。

## ライセンス
この gem は [MIT ライセンス](https://opensource.org/licenses/MIT) の下でオープンソースとして利用可能です。

## 行動規範
JapaneseAddressParser に関してコードを書いたりイシューを追加したりする際は [行動規範](https://github.com/yamat47/japanese_address_parser/blob/main/CODE_OF_CONDUCT.md) に従ってください。
