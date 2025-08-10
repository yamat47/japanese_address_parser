# Ruby再実装 設計方針書

## 1. 設計目標

### 主要目標
- JavaScript（Node.js）への依存を完全に排除
- 既存のRuby APIインターフェースを維持
- JavaScriptライブラリの更新に追従可能な構造
- CSVベースのデータ層は現状維持

### 設計原則
- **関心の分離**: JavaScriptからインスパイアされる部分と独自実装を明確に分離
- **互換性維持**: 既存のgemユーザーに影響を与えない
- **追従可能性**: JS実装の更新を取り込みやすい構造
- **テスタビリティ**: JS実装との互換性を検証可能

## 2. アーキテクチャ設計

### レイヤー構成

```
┌─────────────────────────────────────────────────┐
│           Application Layer (既存維持)           │
│  - JapaneseAddressParser.call/call!            │
│  - Models::Address, Prefecture, City, Town     │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│           Normalization Layer (新規)            │
│  - AddressNormalizer::RubyNormalizer          │
│  - 正規化パイプライン制御                      │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│              Core Layer (新規)                  │
│  ┌──────────────────┐  ┌───────────────────┐ │
│  │  Inspired Modules │  │  Ruby Modules     │ │
│  │  (JS由来の処理)   │  │  (独自実装)       │ │
│  └──────────────────┘  └───────────────────┘ │
└─────────────────────────────────────────────────┘
                        ↓
┌─────────────────────────────────────────────────┐
│               Data Layer (既存維持)              │
│  - CSV files (都道府県・市区町村・町域)         │
│  - JSON files (geolonia-japanese-addresses)    │
└─────────────────────────────────────────────────┘
```

### ディレクトリ構成

```
lib/japanese_address_parser/
├── address_normalizer.rb          # エントリーポイント（修正）
├── address_normalizer/
│   ├── ruby_normalizer.rb        # Ruby実装のメイン
│   └── normalize_japanese_addresses_schmoozer.rb  # 廃止予定
│
├── normalizers/                   # 新規：正規化処理群
│   ├── core/                     # コア正規化ロジック
│   │   ├── inspired/              # JS由来の処理
│   │   │   ├── kanji_variants.rb # 旧字体・新字体変換
│   │   │   ├── zen2han.rb        # 全角→半角変換
│   │   │   ├── kan2num.rb        # 漢数字→アラビア数字
│   │   │   └── text_variants.rb  # 表記ゆらぎ吸収
│   │   │
│   │   └── extensions/            # Ruby独自拡張
│   │       ├── prefecture_matcher.rb
│   │       ├── city_matcher.rb
│   │       └── town_matcher.rb
│   │
│   ├── pipeline.rb               # 正規化パイプライン
│   └── config.rb                 # 設定管理
│
├── compatibility/                 # 新規：互換性維持層
│   ├── js_compatibility_checker.rb
│   └── update_tracker.rb         # JS更新追跡用
│
└── data/                         # 既存維持
    ├── *.csv
    └── geolonia-japanese-addresses/
```

## 3. 実装方針

### 3.1 Core/Inspired モジュール（JS由来）

JavaScriptの実装から移植する処理。コメントでJS実装のバージョンと該当箇所を明記。

```ruby
module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/dict.ts から移植
        class KanjiVariants
          # 旧字体・新字体の変換辞書
          JIS_OLD_KANJI = %w[亞 圍 壹 榮 驛 應 櫻 假 會 懷 覺 樂...]
          JIS_NEW_KANJI = %w[亜 囲 壱 栄 駅 応 桜 仮 会 懐 覚 楽...]
          
          def normalize(text)
            # JS実装の dict.ts#jisKanji 相当
          end
        end
      end
    end
  end
end
```

### 3.2 Core/Extensions モジュール（Ruby独自）

Ruby固有の最適化や拡張機能。

```ruby
module JapaneseAddressParser
  module Normalizers
    module Core
      module Extensions
        class PrefectureMatcher
          # Rubyの高速なマッチング実装
          # CSVデータを活用した効率的な検索
        end
      end
    end
  end
end
```

### 3.3 パイプライン設計

```ruby
module JapaneseAddressParser
  module Normalizers
    class Pipeline
      STAGES = [
        Core::Inspired::Zen2han,        # 1. 全角→半角変換
        Core::Inspired::KanjiVariants,  # 2. 旧字体→新字体
        Core::Inspired::TextVariants,   # 3. 表記ゆらぎ
        Core::Extensions::PrefectureMatcher, # 4. 都道府県マッチ
        Core::Extensions::CityMatcher,       # 5. 市区町村マッチ
        Core::Inspired::Kan2num,        # 6. 漢数字変換
        Core::Extensions::TownMatcher   # 7. 町域マッチ
      ]
      
      def normalize(address)
        result = { original: address, pref: '', city: '', town: '', addr: '' }
        
        STAGES.each do |stage|
          result = stage.new.process(result)
        end
        
        result
      end
    end
  end
end
```

## 4. JavaScript更新への追従戦略

### 4.1 バージョン管理

```yaml
# config/js_compatibility.yml
javascript_library:
  name: "@geolonia/normalize-japanese-addresses"
  tracked_version: "2.10.0"
  last_sync_date: "2024-01-10"
  
tracked_files:
  - path: "src/lib/dict.ts"
    ruby_module: "Core::Inspired::KanjiVariants"
    last_sync_commit: "abc123"
  
  - path: "src/lib/zen2han.ts"
    ruby_module: "Core::Inspired::Zen2han"
    last_sync_commit: "def456"
```

### 4.2 互換性チェッカー

```ruby
module JapaneseAddressParser
  module Compatibility
    class JsCompatibilityChecker
      def check_compatibility
        # テストケースでJS実装とRuby実装の結果を比較
        # 差異があれば警告
      end
      
      def generate_update_report
        # JSライブラリの更新を検知して
        # 変更が必要な箇所をレポート
      end
    end
  end
end
```

### 4.3 更新プロセス

1. **定期チェック**: JSライブラリの更新を監視
2. **差分分析**: 変更された処理を特定
3. **選択的更新**: Core/Inspired モジュールのみ更新
4. **互換性テスト**: 既存テストケースで検証

## 5. 移行計画

### Phase 1: 基盤構築（優先度：高）
- [ ] ディレクトリ構造の作成
- [ ] Core/Inspired モジュールの実装
  - [ ] Zen2han（全角→半角）
  - [ ] KanjiVariants（旧字体→新字体）
  - [ ] TextVariants（表記ゆらぎ）
- [ ] パイプライン基盤の実装

### Phase 2: 正規化処理実装（優先度：高）
- [ ] Kan2num（漢数字変換）の実装
- [ ] 都道府県・市区町村・町域マッチャーの実装
- [ ] 京都通り名処理の実装

### Phase 3: 切り替え準備（優先度：中）
- [ ] RubyNormalizer の実装
- [ ] 既存APIとの接続
- [ ] フィーチャーフラグによる切り替え機能

### Phase 4: 互換性確保（優先度：中）
- [ ] 互換性チェッカーの実装
- [ ] JSとの比較テストスイート
- [ ] パフォーマンステスト

### Phase 5: 移行完了（優先度：低）
- [ ] Schmooze依存の削除
- [ ] package.json の削除
- [ ] ドキュメント更新

## 6. テスト戦略

### 6.1 ユニットテスト
各モジュールごとに独立したテスト

```ruby
RSpec.describe JapaneseAddressParser::Normalizers::Core::Inspired::Zen2han do
  it "全角英数字を半角に変換する" do
    expect(subject.normalize("ＡＢＣ１２３")).to eq("ABC123")
  end
end
```

### 6.2 互換性テスト
JS実装との比較テスト

```ruby
RSpec.describe "JavaScript互換性" do
  it "JS実装と同じ結果を返す" do
    addresses = load_test_addresses
    
    addresses.each do |address|
      ruby_result = RubyNormalizer.call(address)
      js_result = JsNormalizer.call(address) # 比較用
      
      expect(ruby_result).to eq(js_result)
    end
  end
end
```

### 6.3 回帰テスト
既存のgemユーザー向けAPI互換性

```ruby
RSpec.describe JapaneseAddressParser do
  it "既存のAPIが動作する" do
    result = JapaneseAddressParser.call("東京都港区芝公園4-2-8")
    
    expect(result.prefecture.name).to eq("東京都")
    expect(result.city.name).to eq("港区")
    expect(result.town.name).to eq("芝公園四丁目")
  end
end
```

## 7. 設定とカスタマイズ

### 7.1 設定ファイル

```ruby
# config/normalizer.rb
JapaneseAddressParser.configure do |config|
  # 正規化エンジンの選択
  config.normalizer = :ruby  # :ruby or :javascript
  
  # パイプラインのカスタマイズ
  config.pipeline_stages = [
    :zen2han,
    :kanji_variants,
    :text_variants,
    # :custom_stage  # カスタムステージの追加も可能
  ]
  
  # キャッシュ設定
  config.cache_size = 1000
end
```

## 8. パフォーマンス考慮事項

### 最適化ポイント
1. **正規表現のプリコンパイル**: 起動時に正規表現をコンパイル
2. **メモ化**: 変換辞書のキャッシュ
3. **並列処理**: 大量住所の並列正規化オプション
4. **インデックス**: CSVデータの高速検索用インデックス

### ベンチマーク目標
- 単一住所の正規化: < 10ms
- 1000件の一括処理: < 5秒
- メモリ使用量: < 100MB

## 9. リスクと対策

### リスク
1. **互換性の破壊**: 既存ユーザーへの影響
   - 対策: フィーチャーフラグで段階的移行
   
2. **パフォーマンス劣化**: Ruby実装が遅い可能性
   - 対策: 事前のベンチマーク、最適化
   
3. **JS更新への追従コスト**: メンテナンス負荷
   - 対策: 自動化ツール、選択的更新

## 10. まとめ

この設計により、以下を実現します：

1. **Node.js依存の排除**: 純粋なRuby実装
2. **互換性維持**: 既存APIは変更なし
3. **追従可能性**: JS更新を選択的に取り込み可能
4. **拡張性**: Ruby独自の最適化も可能
5. **テスタビリティ**: 各層が独立してテスト可能