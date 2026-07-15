# frozen_string_literal: true

require 'japanese_address_parser/city'
require 'japanese_address_parser/data/single_city'

::RSpec.describe(::JapaneseAddressParser::City) do
  describe '.from_metadata' do
    context 'with nil (city not detected)' do
      it 'returns nil' do
        expect(described_class.from_metadata(nil)).to(be_nil)
      end
    end

    context 'with a plain city (no county, no ward)' do
      subject(:city) { described_class.from_metadata(single_city) }

      let(:single_city) do
        ::JapaneseAddressParser::Data::SingleCity.from_json('code' => 12_025, 'city' => '函館市', 'city_k' => 'ハコダテシ', 'city_r' => 'Hakodate-shi', 'point' => [140.729108, 41.768712])
      end

      it 'maps name (cityName)/code/kana/romaji and leaves county/ward nil' do
        expect(city.name).to(eq('函館市'))
        expect(city.code).to(eq(12_025))
        expect(city.county).to(be_nil)
        expect(city.ward).to(be_nil)
        expect(city.name_kana).to(eq('ハコダテシ'))
        expect(city.name_romaji).to(eq('Hakodate-shi'))
      end

      it 'builds a level-2 representative point with lat/lng swapped from [lng, lat]' do
        expect(city.point.lat).to(eq(41.768712))
        expect(city.point.lng).to(eq(140.729108))
        expect(city.point.level).to(eq(2))
      end
    end

    context 'with a designated-city ward' do
      subject(:city) { described_class.from_metadata(single_city) }

      let(:single_city) do
        ::JapaneseAddressParser::Data::SingleCity.from_json(
          'code' => 14_103,
          'city' => '横浜市',
          'city_k' => 'ヨコハマシ',
          'city_r' => 'Yokohama-shi',
          'ward' => '港北区',
          'ward_k' => 'コウホクク',
          'ward_r' => 'Kohoku-ku',
          'point' => [139.631389, 35.494722]
        )
      end

      it 'composes name from city + ward and exposes ward' do
        expect(city.name).to(eq('横浜市港北区'))
        expect(city.ward).to(eq('港北区'))
      end
    end
  end

  describe '#to_h' do
    it 'deep-converts the nested point' do
      single_city = ::JapaneseAddressParser::Data::SingleCity.from_json('code' => 12_025, 'city' => '函館市', 'city_k' => 'ハコダテシ', 'city_r' => 'Hakodate-shi', 'point' => [140.729108, 41.768712])

      expect(described_class.from_metadata(single_city).to_h).to(
        eq(
          name: '函館市',
          code: 12_025,
          county: nil,
          ward: nil,
          name_kana: 'ハコダテシ',
          name_romaji: 'Hakodate-shi',
          point: { lat: 41.768712, lng: 140.729108, level: 2 }
        )
      )
    end
  end
end
