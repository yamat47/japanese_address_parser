# JavaScript - Ruby 連携アーキテクチャ

## 概要
JapaneseAddressParser は Ruby から JavaScript ライブラリ「@geolonia/normalize-japanese-addresses」を呼び出すアーキテクチャを採用しています。

## アーキテクチャ構成

### 1. JavaScript層

#### ディレクトリ構造
```
js/
├── node_modules/
│   └── @geolonia/normalize-japanese-addresses/  # 正規化ライブラリ本体
├── package.json
└── package-lock.json
```

#### 主要ライブラリ
- **@geolonia/normalize-japanese-addresses v2.10.0**
  - オープンソースの住所正規化ライブラリ
  - TypeScript で実装
  - 経産省の IMI コンポーネントツールからインスピレーション

#### JavaScript側の主要機能
```javascript
// normalize関数の主要機能
normalize(address: string, option: Option) → Promise<NormalizeResult>

// 返り値の構造（v1）
{
  pref: string,      // 都道府県
  city: string,      // 市区町村  
  town: string,      // 町丁目
  addr: string,      // 正規化後の住所文字列
  lat: number|null,  // 緯度
  lng: number|null,  // 経度
  level: number      // 正規化レベル (0-3, 7-8)
}
```

### 2. Ruby層

#### ディレクトリ構造
```
lib/japanese_address_parser/
├── address_normalizer.rb            # JS呼び出しの制御
├── address_normalizer/
│   └── normalize_japanese_addresses_schmoozer.rb  # Schmooze実装
├── address_parser.rb                # 正規化結果のパース
└── data/                           # 都道府県・市区町村データ(CSV)
```

#### Schmoozeによる連携実装
```ruby
class NormalizeJapaneseAddressesSchmoozer < ::Schmooze::Base
  # npmパッケージの場所を指定
  JS_PACKAGE_PATH = '../../../js'
  
  # ローカルの住所データAPIを指定（Web API使用を回避）
  JAPANESE_API_PATH = "file:///.../data/geolonia-japanese-addresses/api/ja"
  
  # JavaScript関数をRubyメソッドとして定義
  dependencies normalize_japanese_addresses: '@geolonia/normalize-japanese-addresses'
  method :set_japanese_api_path, 'function(path) {...}'
  method :normalize, 'normalize_japanese_addresses.normalize'
end
```

### 3. データ層

#### 住所マスタデータ構造
```
lib/japanese_address_parser/data/
├── geolonia-japanese-addresses/
│   └── api/
│       ├── ja.json              # 都道府県・市区町村一覧
│       └── ja/
│           └── 東京都/
│               └── 港区.json    # 町域データ（座標含む）
└── *.csv                        # パース用CSVデータ
```

#### データ形式
- **ja.json**: 都道府県と市区町村のマッピング
- **市区町村.json**: 町域データ（町名、小字、緯度経度）
- **CSVファイル**: 都道府県・市区町村・町域の詳細情報

## 処理フロー

### 全体の流れ
```
1. Ruby: JapaneseAddressParser.call('東京都港区芝公園4-2-8')
   ↓
2. Ruby: AddressNormalizer.call(full_address)
   ↓  
3. Ruby→JS: Schmooze経由でnormalize関数を呼び出し
   ↓
4. JS: 住所を正規化（漢数字変換、ゆらぎ吸収など）
   ↓
5. JS→Ruby: 正規化結果を返却
   ↓
6. Ruby: AddressParser.call(normalized, full_address)
   ↓
7. Ruby: CSVデータと照合して Prefecture/City/Town モデルを生成
   ↓
8. Ruby: Address オブジェクトを返却
```

### 正規化処理の詳細

#### JavaScript側の正規化内容
- 全角英数字を半角に統一
- 郡名の補完（省略されている場合）
- 京都の通り名を削除
- 新字体と旧字体のゆらぎを吸収
- 「ヶケが」「ヵカか」などの表記ゆらぎを吸収
- 町丁目レベルの数字を漢数字に変換
- 番地・号レベルの数字をアラビア数字に変換

#### Ruby側のパース処理
1. 正規化された都道府県名でマッチング
2. 市区町村名でマッチング
3. 町域名でマッチング
4. 各レベルのモデルオブジェクトを生成

## 入出力仕様

### 入力
- **型**: String
- **例**: `"東京都港区芝公園4-2-8"`
- **許容形式**: 
  - 郡名省略可
  - 全角・半角混在可
  - 旧字体使用可

### 出力
- **型**: `JapaneseAddressParser::Models::Address`
- **属性**:
  ```ruby
  {
    full_address: String,     # 元の住所文字列
    prefecture: Prefecture,   # 都道府県モデル
    city: City,              # 市区町村モデル  
    town: Town,              # 町域モデル
    furigana: String         # ふりがな
  }
  ```

### エラーハンドリング
- `call`: 例外をキャッチして nil を返す
- `call!`: `JapaneseAddressParser::NormalizeError` を発生

## 特徴と制約

### 特徴
- ローカルファイルを使用（Web API不要で高速）
- 住所の「名寄せ」に最適化
- 国交省の位置参照情報に準拠

### 制約
- Node.js 実行環境が必須
- 町域レベルまでの対応（番地以降は部分的）
- 住居表示未整備地域は苦手
- 京都の通り名は削除される