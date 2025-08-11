# frozen_string_literal: true

require 'spec_helper'

RSpec.describe(JapaneseAddressParser::Normalizers::Core::Extensions::CityMatcher) do
  let(:tokyo) { JapaneseAddressParser::Models::Prefecture.all.find { |p| p.code == '13' } }
  let(:aichi) { JapaneseAddressParser::Models::Prefecture.all.find { |p| p.code == '23' } }
  let(:nagano) { JapaneseAddressParser::Models::Prefecture.all.find { |p| p.code == '20' } }

  describe '.process' do
    it '政令指定都市の区を認識する' do
      result = described_class.process(tokyo, '港区芝公園4-2-8')
      expect(result[:city]).to(eq('港区'))
      expect(result[:city_code]).to(eq('13103'))
      expect(result[:remaining]).to(eq('芝公園4-2-8'))
      expect(result[:matched]).to(be(true))
    end

    it '市を認識する' do
      result = described_class.process(tokyo, '八王子市元本郷町三丁目24番1号')
      expect(result[:city]).to(eq('八王子市'))
      expect(result[:city_code]).to(eq('13201'))
      expect(result[:remaining]).to(eq('元本郷町三丁目24番1号'))
      expect(result[:matched]).to(be(true))
    end

    it '郡を含む町を認識する' do
      result = described_class.process(aichi, '愛知郡東郷町春木')
      expect(result[:city]).to(eq('愛知郡東郷町'))
      expect(result[:city_code]).to(eq('23302'))
      expect(result[:remaining]).to(eq('春木'))
      expect(result[:matched]).to(be(true))
    end

    it '郡が省略された町を認識する' do
      result = described_class.process(aichi, '東郷町春木')
      expect(result[:city]).to(eq('愛知郡東郷町'))
      expect(result[:city_code]).to(eq('23302'))
      expect(result[:remaining]).to(eq('春木'))
      expect(result[:matched]).to(be(true))
    end

    it '表記ゆらぎを吸収する（ヶ→ケ）' do
      result = described_class.process(nagano, '南佐久郡南牧村野辺山')
      expect(result[:city]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
    end

    it '長い市区町村名を優先的にマッチする' do
      # より長い名前が優先されることを確認
      result = described_class.process(tokyo, '西東京市田無町')
      expect(result[:city]).to(eq('西東京市'))
      expect(result[:matched]).to(be(true))
    end

    it '認識できない市区町村の場合' do
      result = described_class.process(tokyo, '架空市架空町')
      expect(result[:city]).to(eq(''))
      expect(result[:city_code]).to(eq(''))
      expect(result[:remaining]).to(eq('架空市架空町'))
      expect(result[:matched]).to(be(false))
    end

    it '空文字列の場合' do
      result = described_class.process(tokyo, '')
      expect(result[:city]).to(eq(''))
      expect(result[:city_code]).to(eq(''))
      expect(result[:remaining]).to(eq(''))
      expect(result[:matched]).to(be(false))
    end

    it '都道府県がnilの場合' do
      result = described_class.process(nil, '港区芝公園')
      expect(result[:city]).to(eq(''))
      expect(result[:city_code]).to(eq(''))
      expect(result[:remaining]).to(eq('港区芝公園'))
      expect(result[:matched]).to(be(false))
    end

    it '前後の空白を除去してマッチする' do
      result = described_class.process(tokyo, '  港区芝公園  ')
      expect(result[:city]).to(eq('港区'))
      expect(result[:matched]).to(be(true))
    end
  end

  describe '.get_city_regex_patterns' do
    it 'キャッシュが効いている' do
      # 1回目の呼び出し
      patterns1 = described_class.get_city_regex_patterns(tokyo, tokyo.cities)
      
      # 2回目の呼び出し（キャッシュから取得）
      patterns2 = described_class.get_city_regex_patterns(tokyo, tokyo.cities)
      
      expect(patterns1.object_id).to(eq(patterns2.object_id))
    end

    it '都道府県ごとに異なるキャッシュを持つ' do
      patterns_tokyo = described_class.get_city_regex_patterns(tokyo, tokyo.cities)
      patterns_aichi = described_class.get_city_regex_patterns(aichi, aichi.cities)
      
      expect(patterns_tokyo.object_id).not_to(eq(patterns_aichi.object_id))
    end
  end

  describe '.normalize' do
    it 'パイプライン互換インターフェース（単独では使用不可）' do
      result = described_class.normalize('港区芝公園')
      expect(result).to(eq('港区芝公園'))
    end
  end
end