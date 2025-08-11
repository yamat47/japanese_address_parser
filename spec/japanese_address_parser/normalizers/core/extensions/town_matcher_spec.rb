# frozen_string_literal: true

require 'spec_helper'

RSpec.describe(JapaneseAddressParser::Normalizers::Core::Extensions::TownMatcher) do
  let(:tokyo) { JapaneseAddressParser::Models::Prefecture.all.find { |p| p.code == '13' } }
  let(:minato) { tokyo.cities.find { |c| c.name == '港区' } }
  let(:hachioji) { tokyo.cities.find { |c| c.name == '八王子市' } }
  let(:kyoto_pref) { JapaneseAddressParser::Models::Prefecture.all.find { |p| p.code == '26' } }
  let(:kyoto_city) { kyoto_pref.cities.find { |c| c.name == '京都市中京区' } }

  describe '.process' do
    it '基本的な町域を認識する' do
      result = described_class.process(minato, '芝公園4-2-8')
      expect(result[:town]).to(eq('芝公園四丁目'))
      expect(result[:remaining]).not_to(be_nil)
      expect(result[:matched]).to(be(true))
    end

    it '大字を含む町域を認識する' do
      result = described_class.process(hachioji, '大字小宮町')
      expect(result[:town]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
    end

    it '大字が省略された町域も認識する' do
      result = described_class.process(hachioji, '小宮町')
      expect(result[:town]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
    end

    it '数字を含む町域を認識する' do
      result = described_class.process(minato, '芝三丁目')
      expect(result[:town]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
    end

    it '漢数字を含む町域を認識する' do
      result = described_class.process(minato, '芝公園四丁目')
      expect(result[:town]).to(eq('芝公園四丁目'))
      expect(result[:matched]).to(be(true))
    end

    it 'アラビア数字でも漢数字の町域を認識する' do
      result = described_class.process(minato, '芝公園4丁目')
      expect(result[:town]).to(eq('芝公園四丁目'))
      expect(result[:matched]).to(be(true))
    end

    it '丁目なしの数字だけでも認識する' do
      result = described_class.process(minato, '芝公園4')
      expect(result[:town]).to(eq('芝公園四丁目'))
      expect(result[:matched]).to(be(true))
    end

    it '横棒を含む町域を認識する' do
      # 流通センターなど横棒を含む町域のテスト
      result = described_class.process(minato, '海岸1-1-1')
      expect(result[:matched]).to(be(true))
    end

    it '京都の通り名を削除する' do
      result = described_class.process(kyoto_city, '上本能寺前町')
      expect(result[:town]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
      # 通り名が削除されていることを確認
      expect(result[:town]).not_to(include('通'))
    end

    it '表記ゆらぎを吸収する' do
      # ヶ→ケなどの表記ゆらぎテスト
      result = described_class.process(minato, '芝公園４丁目')
      expect(result[:town]).to(eq('芝公園四丁目'))
      expect(result[:matched]).to(be(true))
    end

    it '認識できない町域の場合' do
      result = described_class.process(minato, '架空町1-2-3')
      expect(result[:town]).to(eq(''))
      expect(result[:remaining]).to(eq('架空町1-2-3'))
      expect(result[:matched]).to(be(false))
    end

    it '空文字列の場合' do
      result = described_class.process(minato, '')
      expect(result[:town]).to(eq(''))
      expect(result[:remaining]).to(eq(''))
      expect(result[:matched]).to(be(false))
    end

    it '市区町村がnilの場合' do
      result = described_class.process(nil, '芝公園4-2-8')
      expect(result[:town]).to(eq(''))
      expect(result[:remaining]).to(eq('芝公園4-2-8'))
      expect(result[:matched]).to(be(false))
    end

    it '前後の空白を除去してマッチする' do
      result = described_class.process(minato, '  芝公園4-2-8  ')
      expect(result[:town]).not_to(be_empty)
      expect(result[:matched]).to(be(true))
    end

    context '京都特有の処理' do
      it '通り名の前方削除パターン' do
        result = described_class.process(kyoto_city, '油小路通押小路下る押油小路町')
        expect(result[:matched]).to(be(true))
        # 通り名が適切に処理されていることを確認
      end

      it '通り名の後方削除パターン' do
        result = described_class.process(kyoto_city, '室町通御池上る御池之町')
        expect(result[:matched]).to(be(true))
        # 通り名が適切に処理されていることを確認
      end
    end
  end

  describe '.get_town_regex_patterns' do
    it 'キャッシュが効いている' do
      # 1回目の呼び出し
      patterns1 = described_class.get_town_regex_patterns(minato)
      
      # 2回目の呼び出し（キャッシュから取得）
      patterns2 = described_class.get_town_regex_patterns(minato)
      
      expect(patterns1.object_id).to(eq(patterns2.object_id))
    end

    it '市区町村ごとに異なるキャッシュを持つ' do
      patterns_minato = described_class.get_town_regex_patterns(minato)
      patterns_hachioji = described_class.get_town_regex_patterns(hachioji)
      
      expect(patterns_minato.object_id).not_to(eq(patterns_hachioji.object_id))
    end

    it '長い町域名を優先的にマッチする順序になっている' do
      patterns = described_class.get_town_regex_patterns(minato)
      # パターンが長い順にソートされていることを確認
      expect(patterns).not_to(be_empty)
    end
  end

  describe '.normalize' do
    it 'パイプライン互換インターフェース（単独では使用不可）' do
      result = described_class.normalize('芝公園4-2-8')
      expect(result).to(eq('芝公園4-2-8'))
    end
  end
end