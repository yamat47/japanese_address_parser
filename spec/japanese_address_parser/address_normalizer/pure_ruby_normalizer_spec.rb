# frozen_string_literal: true

require 'rspec'
require_relative '../../../lib/japanese_address_parser/address_normalizer/pure_ruby_normalizer'

::RSpec.describe(::JapaneseAddressParser::AddressNormalizer::PureRubyNormalizer) do
  describe '.call' do
    context '正常なケース' do
      it '東京都渋谷区恵比寿を正しく解析する' do
        result = described_class.call('東京都渋谷区恵比寿1-1-1')
        
        expect(result).to include(
          'pref' => '東京都',
          'city' => '渋谷区',
          'town' => '恵比寿一丁目',
          'level' => 3
        )
        expect(result['addr']).to be_a(String)
        expect(result['lat']).to be_a(Float).or(be_nil)
        expect(result['lng']).to be_a(Float).or(be_nil)
      end

      it '正規化が必要な住所を正しく処理する' do
        result = described_class.call('　東京都　渋谷区　恵比寿　１－１－１　')
        
        expect(result).to include(
          'pref' => '東京都',
          'city' => '渋谷区'
        )
        expect(result['level']).to be >= 2
      end
    end

    context 'エラーケース' do
      it '空文字列の場合' do
        result = described_class.call('')
        
        expect(result).to include(
          'pref' => '',
          'city' => '',
          'town' => '',
          'level' => 0
        )
      end

      it 'nilの場合' do
        result = described_class.call(nil)
        
        expect(result).to include(
          'pref' => '',
          'city' => '',
          'town' => '',
          'level' => 0
        )
      end

      it '不正な住所の場合' do
        result = described_class.call('存在しない都道府県')
        
        expect(result).to include(
          'pref' => '',
          'city' => '',
          'town' => '',
          'level' => 0
        )
      end
    end

    context 'レベル別の解析' do
      it '都道府県のみ特定できる場合はレベル1' do
        result = described_class.call('東京都')
        
        expect(result).to include(
          'pref' => '東京都',
          'city' => '',
          'town' => '',
          'level' => 1
        )
      end

      it '市区町村まで特定できる場合はレベル2' do
        result = described_class.call('東京都渋谷区')
        
        expect(result).to include(
          'pref' => '東京都',
          'city' => '渋谷区',
          'town' => '',
          'level' => 2
        )
      end

      it '町丁目まで特定できる場合はレベル3' do
        result = described_class.call('東京都渋谷区恵比寿1-1-1')
        
        expect(result).to include(
          'level' => 3
        )
        expect(result['town']).not_to be_empty
      end
    end
  end
end