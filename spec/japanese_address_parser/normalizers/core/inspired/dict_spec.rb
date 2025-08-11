# frozen_string_literal: true

require 'spec_helper'
require 'japanese_address_parser/normalizers/core/inspired/dict'

RSpec.describe JapaneseAddressParser::Normalizers::Core::Inspired::Dict do
  describe '.jis_kanji' do
    it '旧字体を正規表現パターンに変換する' do
      result = described_class.jis_kanji('渋谷區')
      expect(result).to eq('(澁|渋)谷(區|区)')
    end

    it '新字体を正規表現パターンに変換する' do
      result = described_class.jis_kanji('渋谷区')
      expect(result).to eq('(澁|渋)谷(區|区)')
    end

    it '複数の旧字体を変換する' do
      result = described_class.jis_kanji('壹番町參丁目')
      expect(result).to eq('(壹|壱)番町(參|参)丁目')
    end

    it '変換対象外の文字はそのまま' do
      result = described_class.jis_kanji('東京都')
      expect(result).to eq('東京都')
    end
  end

  describe '.to_regex_pattern' do
    it '「ヶ」「ケ」「が」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('霞ヶ関')
      expect(result).to eq('霞[ヶケが](關|関)')
    end

    it '「の」「ノ」「之」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('木ノ本町')
      expect(result).to eq('木[之ノの]本町')
    end

    it '「ツ」「ッ」「つ」「っ」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('三ツ谷')
      expect(result).to eq('三[ッツっつ]谷')
    end

    it '「ニ」「二」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('二本松')
      expect(result).to eq('[ニ二]本松')
    end

    it '「ハ」「八」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('八幡町')
      expect(result).to eq('[ハ八]幡町')
    end

    it '「通り」「とおり」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('新宿通り')
      # 新宿のような旧字体がない地名を使う
      expect(result).to eq('新宿(通り|とおり)')
    end

    it '「埠頭」「ふ頭」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('横浜埠頭')
      # 横浜には濱という旧字体があるため
      expect(result).to eq('横(濱|浜)(埠頭|ふ頭)')
    end

    it '「番町」「番丁」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('一番町')
      expect(result).to eq('一(番町|番丁)')
    end

    it '「條」「条」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('三条')
      # シンプルな例にする
      expect(result).to eq('三(條|条)')
    end

    it '「市」「巿」を統一パターンに変換する' do
      result = described_class.to_regex_pattern('巿川市')
      expect(result).to eq('(市|巿)川(市|巿)')
    end

    it '複数のパターンを同時に処理する' do
      result = described_class.to_regex_pattern('霞ヶ関二丁目')
      expect(result).to eq('霞[ヶケが](關|関)[ニ二]丁目')
    end

    it 'JIS漢字変換も含めて処理する' do
      result = described_class.to_regex_pattern('澁谷區')
      expect(result).to eq('(澁|渋)谷(區|区)')
    end

    context '特殊な地名パターン' do
      it '三栄町と四谷三栄町を処理する' do
        result = described_class.to_regex_pattern('三栄町')
        # 栄には榮という旧字体があるため
        expect(result).to eq('(三(榮|栄)町|四谷三(榮|栄)町)')
      end

      it '鬮野川のバリエーションを処理する' do
        result = described_class.to_regex_pattern('鬮野川')
        # 「の」は[之ノの]に変換される
        expect(result).to eq('(鬮野川|くじ野川|くじ[之ノの]川)')
      end

      it '柿碕町のバリエーションを処理する' do
        result = described_class.to_regex_pattern('柿碕町')
        expect(result).to eq('(柿碕町|柿さき町)')
      end
    end
  end
end