# Ruby再実装 TODOリスト

## 概要
JavaScriptライブラリへの依存を排除し、純粋なRuby実装に移行するためのタスクリスト。

## Phase 1: 基盤構築 🏗️

### ディレクトリ構造
- [x] `lib/japanese_address_parser/normalizers/` ディレクトリを作成
- [x] `lib/japanese_address_parser/normalizers/core/` ディレクトリを作成
- [x] `lib/japanese_address_parser/normalizers/core/inspired/` ディレクトリを作成
- [x] `lib/japanese_address_parser/normalizers/core/extensions/` ディレクトリを作成
- [x] `lib/japanese_address_parser/compatibility/` ディレクトリを作成

### Core/Inspired モジュール（JS由来の処理）
- [x] `normalizers/core/inspired/zen2han.rb` - 全角→半角変換
  - [x] 全角英数字→半角英数字の変換実装
  - [x] テストケース作成
  - [x] JSとの互換性確認
  
- [x] `normalizers/core/inspired/kanji_variants.rb` - 旧字体・新字体変換
  - [x] JIS第2水準→第1水準の変換辞書作成
  - [x] 旧字体→新字体の変換辞書作成
  - [x] 変換ロジックの実装
  - [x] テストケース作成
  
- [x] `normalizers/core/inspired/text_variants.rb` - 表記ゆらぎ吸収
  - [x] 「ヶケが」の統一処理
  - [x] 「ヵカか力」の統一処理  
  - [x] 「之ノの」の統一処理
  - [x] 「ッツっつ」の統一処理
  - [x] その他のゆらぎ（埠頭/ふ頭、番町/番丁など）
  - [x] テストケース作成

### パイプライン基盤
- [x] `normalizers/pipeline.rb` - 正規化パイプライン
  - [x] パイプラインインターフェース定義
  - [x] ステージの連結処理
  - [x] エラーハンドリング
  
- [x] `normalizers/config.rb` - 設定管理
  - [x] デフォルト設定
  - [x] カスタマイズ可能な設定項目

## Phase 2: 正規化処理実装 🔧

### 漢数字変換
- [x] `normalizers/core/inspired/kan2num.rb` - 漢数字→アラビア数字
  - [x] 基本的な漢数字変換（一〜九）
  - [x] 十進法の処理（十、百、千、万）
  - [x] 特殊な表記への対応（丁目、番地など）
  - [x] テストケース作成

### 住所マッチング（Ruby独自）
- [x] `normalizers/core/extensions/prefecture_matcher.rb`
  - [x] 都道府県データのロード
  - [x] 高速マッチングアルゴリズム（Trie実装）
  - [x] 省略形への対応（東京→東京都など）
  
- [x] `normalizers/core/extensions/city_matcher.rb`
  - [x] 市区町村データのロード
  - [x] 郡名の補完処理
  - [x] 政令指定都市の区への対応
  
- [x] `normalizers/core/extensions/town_matcher.rb`
  - [x] 町域データのロード
  - [x] 丁目・番地の正規化
  - [x] 小字への対応

### 特殊ケース処理
- [x] 京都の通り名削除処理
- [x] 住居表示と地番の判別
- [ ] 建物名の分離（オプション）

## Phase 3: 切り替え準備 🔄

### Ruby実装の統合
- [x] `address_normalizer/pure_ruby_normalizer.rb` - Ruby実装のメイン
  - [x] パイプラインの呼び出し
  - [x] 結果の整形（JS互換フォーマット）
  - [x] エラーハンドリング
  - [x] Matcherモジュールとの統合

### API接続
- [x] `address_normalizer.rb` の修正
  - [x] 実装切り替えロジック
  - [x] Pure Ruby実装をデフォルトに設定
  - [x] 後方互換性の確保

### 設定システム
- [ ] 環境変数による切り替え（`JAPANESE_ADDRESS_PARSER_ENGINE`）
- [ ] 設定ファイルによる切り替え
- [ ] 実行時の動的切り替え

## Phase 4: 互換性確保 ✅

### 互換性チェッカー
- [x] `compatibility/js_compatibility_checker.rb`
  - [x] JS実装との結果比較
  - [x] 差分レポート生成
  - [x] パフォーマンス比較

### テストスイート
- [x] 既存テストの全パス確認
- [x] JS実装との比較テスト追加
  - [x] 基本的な住所パターン（100件）
  - [x] エッジケース（旧字体、通り名など）
  - [x] 大量データでの検証（1000件以上）

### パフォーマンステスト
- [x] ベンチマークスクリプト作成
- [x] メモリ使用量の測定
- [x] 処理速度の比較（JS vs Ruby）

### バージョン管理
- [ ] `config/js_compatibility.yml` の作成
- [ ] 追跡対象ファイルの記録
- [ ] 更新履歴の管理

## Phase 5: 移行完了 🎉

### クリーンアップ
- [ ] Schmooze gem の依存削除
- [ ] `normalize_japanese_addresses_schmoozer.rb` の削除
- [ ] `js/` ディレクトリの削除
- [ ] `package.json`, `package-lock.json` の削除
- [ ] Node.js関連の設定削除

### ドキュメント更新
- [ ] README.md の更新
  - [ ] Node.js不要の明記
  - [ ] インストール手順の簡略化
  - [ ] パフォーマンス向上の記載
  
- [ ] CHANGELOG.md の更新
- [ ] マイグレーションガイドの作成
- [ ] API ドキュメントの更新

### リリース準備
- [ ] バージョン番号の決定（メジャーバージョンアップ？）
- [ ] リリースノートの作成
- [ ] gem のビルドとテスト
- [ ] ベータ版のリリース
- [ ] フィードバック収集期間
- [ ] 正式版リリース

## 補足タスク 📝

### 継続的メンテナンス
- [ ] JS実装の更新監視スクリプト
- [ ] 定期的な互換性チェック
- [ ] パフォーマンス回帰テスト

### オプション機能
- [ ] 並列処理対応（大量住所の一括処理）
- [ ] キャッシュ機構の実装
- [ ] プラグインシステム（カスタムステージ追加）

## 進捗管理 📊

### 完了基準
- すべてのテストがパス
- パフォーマンスがJS実装と同等以上
- メモリ使用量が許容範囲内
- ドキュメントが最新

### マイルストーン
- **M1**: Phase 1 完了 - 基盤構築完了 ✅ (2025-08-11)
- **M2**: Phase 2 完了 - 基本機能動作 ✅ (2025-08-11)
  - JavaScript実装のロジックを忠実に移植
  - 正規表現パターンベースのマッチング実装
  - toRegexPattern/jisKanjiの移植完了
  - Dict, PatchAddr, AddressPostprocessor実装完了
- **M3**: Phase 3 完了 - 切り替え可能 ✅ (Pure Ruby実装をデフォルト化)
- **M4**: Phase 4 完了 - 本番投入可能 ✅ (2025-08-11)
  - 互換性チェッカー実装
  - テストスイート完成
  - パフォーマンスベンチマーク作成
- **M5**: Phase 5 完了 - 移行完了

## 注意事項 ⚠️

1. **後方互換性**: 既存ユーザーへの影響を最小限に
2. **段階的移行**: フィーチャーフラグで慎重に切り替え
3. **テスト重視**: 各ステップで十分なテストを実施
4. **ドキュメント**: 変更内容を明確に記録

## 関連ドキュメント 📚

- [設計方針書](./ruby_reimplementation_design.md)
- [現在のアーキテクチャ](./javascript_ruby_integration_architecture.md)
- [CLAUDE.md](../CLAUDE.md)