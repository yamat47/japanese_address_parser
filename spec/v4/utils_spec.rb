# frozen_string_literal: true

require 'japanese_address_parser/v4/utils'
require 'japanese_address_parser/v4/data/single_prefecture'
require 'japanese_address_parser/v4/data/single_machi_aza'

::RSpec.describe(::JapaneseAddressParser::V4::Utils) do
  describe '.remove_cities_from_prefecture' do
    subject(:result) { described_class.remove_cities_from_prefecture(prefecture) }

    let(:prefecture) do
      ::JapaneseAddressParser::V4::Data::SinglePrefecture.from_json('code' => 13, 'pref' => '東京都', 'pref_k' => 'トウキョウト', 'pref_r' => 'Tokyo', 'point' => [139.7, 35.6], 'cities' => [{ 'code' => 13_101 }])
    end

    context 'when the prefecture is nil' do
      let(:prefecture) { nil }

      it 'returns nil' do
        expect(result).to(be_nil)
      end
    end

    it 'returns a Hash without the cities key' do
      expect(result).to(be_a(::Hash))
      expect(result).not_to(have_key(:cities))
    end

    it 'keeps the other fields intact' do
      expect(result).to(eq({ code: 13, pref: '東京都', pref_k: 'トウキョウト', pref_r: 'Tokyo', point: [139.7, 35.6] }))
    end

    it 'does not mutate the original prefecture' do
      result
      expect(prefecture.cities.size).to(eq(1))
    end
  end

  describe '.remove_extra_from_machi_aza' do
    subject(:result) { described_class.remove_extra_from_machi_aza(machi_aza) }

    let(:machi_aza) do
      ::JapaneseAddressParser::V4::Data::SingleMachiAza.from_json(
        'machiaza_id' => '0001',
        'oaza_cho' => '道玄坂',
        'chome' => '一丁目',
        'rsdt' => true,
        'point' => [139.6, 35.6],
        'csv_ranges' => { '住居表示' => { 'start' => 0, 'length' => 10 } }
      )
    end

    context 'when the machi_aza is nil' do
      let(:machi_aza) { nil }

      it 'returns nil' do
        expect(result).to(be_nil)
      end
    end

    it 'returns a Hash without the csv_ranges key' do
      expect(result).to(be_a(::Hash))
      expect(result).not_to(have_key(:csv_ranges))
    end

    it 'keeps the other fields intact' do
      expect(result[:machiaza_id]).to(eq('0001'))
      expect(result[:oaza_cho]).to(eq('道玄坂'))
      expect(result[:chome]).to(eq('一丁目'))
      expect(result[:rsdt]).to(be(true))
    end

    it 'does not mutate the original machi_aza' do
      result
      expect(machi_aza.csv_ranges).not_to(be_nil)
    end
  end
end
