# frozen_string_literal: true

require 'japanese_address_parser/address'
require 'japanese_address_parser/normalize_result'
require 'japanese_address_parser/normalize_result_point'
require 'japanese_address_parser/data/single_city'

::RSpec.describe(::JapaneseAddressParser::Address) do
  describe '.from_normalize_result' do
    context 'with a fully matched result (level 3)' do
      subject(:address) { described_class.from_normalize_result(result) }

      let(:single_city) do
        ::JapaneseAddressParser::Data::SingleCity.from_json(
          'code' => 14_109,
          'city' => '横浜市',
          'city_k' => 'ヨコハマシ',
          'city_r' => 'Yokohama-shi',
          'ward' => '港北区',
          'ward_k' => 'コウホクク',
          'ward_r' => 'Kohoku-ku',
          'point' => [139.631, 35.507]
        )
      end
      let(:metadata) do
        ::JapaneseAddressParser::NormalizeResultMetadata.new(
          input: '神奈川県横浜市港北区大豆戸町一丁目',
          prefecture: { code: 14, pref: '神奈川県', pref_k: 'カナガワケン', pref_r: 'Kanagawa', point: [139.642, 35.447] },
          city: single_city,
          machi_aza: { machiaza_id: '0001001', oaza_cho: '大豆戸町', chome: '一丁目', chome_n: 1, koaza: nil, point: [139.625, 35.508] },
          chiban: nil,
          rsdt: nil
        )
      end
      let(:result) do
        ::JapaneseAddressParser::NormalizeResult.new(
          pref: '神奈川県',
          city: '横浜市港北区',
          town: '大豆戸町一丁目',
          addr: nil,
          other: '',
          point: ::JapaneseAddressParser::NormalizeResultPoint.new(lat: 35.508, lng: 139.625, level: 3),
          level: 3,
          metadata:
        )
      end

      it 'maps the original input to full_address' do
        expect(address.full_address).to(eq('神奈川県横浜市港北区大豆戸町一丁目'))
      end

      it 'builds the nested rich VOs' do
        expect(address.prefecture.name).to(eq('神奈川県'))
        expect(address.city.name).to(eq('横浜市港北区'))
        expect(address.town.name).to(eq('大豆戸町一丁目'))
        expect(address.town.chome_n).to(eq(1))
      end

      it 'passes through addr/other/point/level and keeps metadata as the raw escape hatch' do
        expect(address.addr).to(be_nil)
        expect(address.other).to(eq(''))
        expect(address.point.level).to(eq(3))
        expect(address.level).to(eq(3))
        expect(address.metadata).to(equal(metadata))
      end
    end

    context 'with an unmatched result (level 0)' do
      subject(:address) { described_class.from_normalize_result(result) }

      let(:metadata) do
        ::JapaneseAddressParser::NormalizeResultMetadata.new(input: 'まったく住所ではない文字列', prefecture: nil, city: nil, machi_aza: nil, chiban: nil, rsdt: nil)
      end
      let(:result) do
        ::JapaneseAddressParser::NormalizeResult.new(pref: nil, city: nil, town: nil, addr: nil, other: 'まったく住所ではない文字列', point: nil, level: 0, metadata:)
      end

      it 'leaves the nested VOs nil (unmatched is not a failure)' do
        expect(address.prefecture).to(be_nil)
        expect(address.city).to(be_nil)
        expect(address.town).to(be_nil)
        expect(address.level).to(eq(0))
        expect(address.point).to(be_nil)
      end
    end
  end

  describe '#to_h' do
    let(:metadata) do
      ::JapaneseAddressParser::NormalizeResultMetadata.new(input: 'まったく住所ではない文字列', prefecture: nil, city: nil, machi_aza: nil, chiban: nil, rsdt: nil)
    end
    let(:result) do
      ::JapaneseAddressParser::NormalizeResult.new(pref: nil, city: nil, town: nil, addr: nil, other: 'まったく住所ではない文字列', point: nil, level: 0, metadata:)
    end

    it 'deep-converts nested VOs and shallow-converts metadata' do
      expect(described_class.from_normalize_result(result).to_h).to(
        eq(
          full_address: 'まったく住所ではない文字列',
          prefecture: nil,
          city: nil,
          town: nil,
          addr: nil,
          other: 'まったく住所ではない文字列',
          point: nil,
          level: 0,
          metadata: {
            input: 'まったく住所ではない文字列',
            prefecture: nil,
            city: nil,
            machi_aza: nil,
            chiban: nil,
            rsdt: nil
          }
        )
      )
    end
  end
end
