![CI Status](https://github.com/yamat47/japanese_address_parser/actions/workflows/ci.yml/badge.svg) [![Gem Version](https://badge.fury.io/rb/japanese_address_parser.svg)](https://badge.fury.io/rb/japanese_address_parser)

# JapaneseAddressParser

JapaneseAddressParser は日本の住所を正規化する Ruby gem です。

[@geolonia/normalize-japanese-addresses](https://github.com/geolonia/normalize-japanese-addresses)
**v3.1.3** の忠実な Ruby 移植で、住所データは配信 API から実行時に取得します。**Node.js は不要**です。

## インストール

`Gemfile` に追記して `bundle install`：

```ruby
gem 'japanese_address_parser'
```

Ruby 3.2 以上が必要です。

## 使い方

```ruby
address = JapaneseAddressParser.call('渋谷区道玄坂1-10-8')

address.prefecture.name        #=> "東京都"
address.prefecture.code        #=> 130001
address.prefecture.name_kana   #=> "トウキョウト"
address.prefecture.name_romaji #=> "Tokyo"

address.city.name              #=> "渋谷区"
address.town.name              #=> "道玄坂一丁目"
address.town.chome             #=> "一丁目"
address.town.chome_n           #=> 1

address.addr                   #=> "10-8"   # 住居表示 or 地番（level 8）
address.other                  #=> ""       # 末尾の未正規化部
address.level                  #=> 8        # 0/1/2/3/8
address.point                  #=> #<... lat: 35.6568..., lng: 139.6987..., level: 8>

address.to_h                   # ネスト VO・座標も含めた Hash
address.metadata               # VO に昇格しない生データ（rsdt/chiban 等）の逃がし道
```

### 戻り値と例外

- `call` / `call!` は**常に `Address` を返します**。都道府県すら判別できなくても `level 0` の `Address` を返します（未マッチは失敗ではありません）。
- `nil`／例外になるのは**データ取得（fetch）失敗時のみ**です。`call` は `nil` を返し、`call!` は `JapaneseAddressParser::NormalizeError` を raise します。
- 正規化レベルは毎回 `level:` で指定できます（既定は `8`）。

```ruby
JapaneseAddressParser.call('神奈川県横浜市港北区', level: 2).level #=> 2
JapaneseAddressParser.call!('渋谷区道玄坂1-10-8')                   # fetch 失敗時は NormalizeError
```

## 設定

```ruby
JapaneseAddressParser.configure do |c|
  # データ源。既定はリモート API。
  c.japanese_addresses_api = 'https://japanese-addresses-v2.geoloniamaps.com/api/ja'
  # 町字パターンの LRU キャッシュサイズ（既定 1000）。
  c.cache_size = 1_000
end
```

- `http://` / `https://` で始まる → HTTP で取得（level 8 は Range 部分取得）。
- `file://` で始まる、または絶対/相対パス → ローカルファイルから取得（ミラーを置いて利用できます）。
- 住所データは gem に**同梱していません**（level 3 で約 100MB、level 8 で数 GB のため）。

## スレッド安全性

本 gem は**スレッドセーフではありません**（上流 JS と同じくモジュールレベルのキャッシュを使います）。
マルチスレッドで使う場合は、**起動時に代表的な住所を1回正規化してキャッシュを暖機**しておくことを推奨します。

## 移植元（アップストリーム）

```ruby
JapaneseAddressParser::UPSTREAM_VERSION    #=> "3.1.3"
JapaneseAddressParser::UPSTREAM_COMMIT_SHA #=> "49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e"
```

## v4.0.0 について

v4.0.0 で Node.js / `schmooze` 依存を撤去し、上流 v3.1.3 を Ruby に逐語移植しました。
公開 API・戻り値の形は v3.x から変わっています（後方互換はありません）。
