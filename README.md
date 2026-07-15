![CI Status](https://github.com/yamat47/japanese_address_parser/actions/workflows/ci.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/japanese_address_parser.svg)](https://badge.fury.io/rb/japanese_address_parser)

# JapaneseAddressParser

JapaneseAddressParser は日本の住所を正規化する Ruby 用のライブラリです。「東京都渋谷区道玄坂1-10-8」のような住所の文字列を受け取り、都道府県・市区町村・町名・番地に分解します。

住所の正規化には geolonia の [normalize-japanese-addresses](https://github.com/geolonia/normalize-japanese-addresses) と同じ仕組みを使っています。

## インストール

Gemfile に次の行を追加して `bundle install` を実行してください。

```ruby
gem 'japanese_address_parser'
```

Ruby 3.2 以降が必要です。

## 使い方

`JapaneseAddressParser.call` に住所の文字列を渡すと、正規化した結果を返します。

```ruby
address = JapaneseAddressParser.call('東京都渋谷区道玄坂1-10-8')

address.prefecture.name #=> "東京都"
address.city.name       #=> "渋谷区"
address.town.name       #=> "道玄坂一丁目"
address.addr            #=> "10-8"
address.other           #=> ""
address.level           #=> 8
```

都道府県・市区町村・町名には、名前のほかに読みがな・ローマ字・行政コードなどの情報も含まれています。

```ruby
address.prefecture.name        #=> "東京都"
address.prefecture.code        #=> 130001
address.prefecture.name_kana   #=> "トウキョウト"
address.prefecture.name_romaji #=> "Tokyo"

address.town.chome   #=> "一丁目"
address.town.chome_n #=> 1

address.point #=> 緯度・経度とその精度
address.to_h  #=> 住所全体をハッシュに変換する
```

### 正規化のレベル

住所をどこまで判別できたかは `level` で表されます。

- 0: 都道府県も判別できなかった
- 1: 都道府県まで判別できた
- 2: 市区町村まで判別できた
- 3: 町名まで判別できた
- 8: 住居表示または地番まで判別できた

どのレベルまで判別するかは呼び出しごとに指定できます。指定しない場合は 8 まで判別します。

```ruby
JapaneseAddressParser.call('神奈川県横浜市港北区', level: 2).level #=> 2
```

### 戻り値と例外

`call` は常に住所を返します。都道府県すら判別できなかった場合でも、`level` が 0 の住所を返します。住所として認識できないこと自体はエラーではありません。

住所データの取得に失敗したときだけ、戻り値が変わります。`call` は `nil` を返し、`call!` は `JapaneseAddressParser::NormalizeError` を発生させます。

```ruby
JapaneseAddressParser.call('あいうえお').level #=> 0
JapaneseAddressParser.call!('東京都渋谷区道玄坂1-10-8') # 取得に失敗すると例外
```

## 設定

`JapaneseAddressParser.configure` で動作を設定できます。

```ruby
JapaneseAddressParser.configure do |config|
  config.japanese_addresses_api = 'https://japanese-addresses-v2.geoloniamaps.com/api/ja'
  config.cache_size = 1000
end
```

設定できる項目は次の3つです。

| 設定項目 | 説明 |
| --- |  --- |
| `japanese_addresses_api` | 住所データの取得先。指定しない場合は geolonia の配信 API を参照します。`file://` で始まる値やローカルのパスを指定すると手元の住所ファイルを使うこともできます。 |
| `cache_size` | 町名の照合に使う正規表現のキャッシュ上限。指定しない場合は 1000 。 |

