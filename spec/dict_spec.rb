# frozen_string_literal: true

require 'japanese_address_parser/dict'

::RSpec.describe(::JapaneseAddressParser::Dict) do
  describe '.to_regex_pattern' do
    it 'expands a spelling-variant alternation in both directions' do
      expect(described_class.to_regex_pattern('通り')).to(eq('(通り|とおり)'))
      expect(described_class.to_regex_pattern('とおり')).to(eq('(通り|とおり)'))
    end

    it 'expands a kanji/kana alternation' do
      expect(described_class.to_regex_pattern('番町')).to(eq('(番町|番丁)'))
      expect(described_class.to_regex_pattern('番丁')).to(eq('(番町|番丁)'))
    end

    it 'replaces each member of a character class with the class itself' do
      expect(described_class.to_regex_pattern('の')).to(eq('[之ノの]'))
      expect(described_class.to_regex_pattern('之')).to(eq('[之ノの]'))
      expect(described_class.to_regex_pattern('ノ')).to(eq('[之ノの]'))
    end

    it 'rewrites a character class inside a longer string' do
      expect(described_class.to_regex_pattern('ヶ丘')).to(eq('[ヶケが]丘'))
    end

    # 見た目が同じでもコードポイントが異なるペアを厳密に保持する（上流 TS から生成）。
    # 各 expect の直前コメントに対応コードポイントを明記する。
    it 'preserves look-alike but distinct code points' do
      # 塚 U+585A vs 塚 U+FA10
      expect(described_class.to_regex_pattern('塚')).to(eq('(塚|塚)'))
      # 崎 U+5D0E vs 﨑 U+FA11
      expect(described_class.to_regex_pattern('崎')).to(eq('(崎|﨑)'))
      expect(described_class.to_regex_pattern('﨑')).to(eq('(崎|﨑)'))
      # 市 U+5E02 vs 巿 U+5DFF
      expect(described_class.to_regex_pattern('市')).to(eq('(市|巿)'))
    end

    # チェーンの後段 gsub が前段の出力をさらに書き換える（順序依存）挙動を逐語再現する。
    # '薭|稗|ひえ|ヒエ' → '(薭|稗|ひえ|ヒエ)' の後に 'エ|ヱ|え' 置換が内側の え/エ を展開する。
    it 'applies later replacements to the output of earlier ones (chain order matters)' do
      expect(described_class.to_regex_pattern('薭')).to(eq('(薭|稗|ひ(エ|ヱ|え)|ヒ(エ|ヱ|え))'))
      expect(described_class.to_regex_pattern('ヒエ')).to(eq('(薭|稗|ひ(エ|ヱ|え)|ヒ(エ|ヱ|え))'))
    end

    # 末尾の Dictionaries::Convert により、辞書の旧/新字体も両方マッチパターンへ展開される。
    it 'runs the dictionary convert step at the end' do
      # 区 は jisDai2 の dst（區 => 区）なので convert が展開する
      expect(described_class.to_regex_pattern('区')).to(eq('(區|区)'))
      # チェーンで括られた後、内側の 栄（榮 => 栄 の dst）も convert で展開される
      expect(described_class.to_regex_pattern('三栄町')).to(eq('(三(榮|栄)町|四谷三(榮|栄)町)'))
    end

    it 'leaves a string with no matching rules unchanged' do
      expect(described_class.to_regex_pattern('東京都')).to(eq('東京都'))
    end
  end
end
