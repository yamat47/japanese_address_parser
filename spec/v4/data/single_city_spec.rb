# frozen_string_literal: true

require 'japanese_address_parser/v4/data/single_city'

::RSpec.describe(::JapaneseAddressParser::V4::Data::SingleCity) do
  describe '.from_json' do
    context 'with a plain city (no county, no ward)' do
      subject(:city) { described_class.from_json(hash) }

      let(:hash) do
        {
          'code' => 12_025,
          'city' => '函館市',
          'city_k' => 'ハコダテシ',
          'city_r' => 'Hakodate-shi',
          'point' => [140.729108, 41.768712]
        }
      end

      it 'maps present fields and leaves absent optionals nil' do
        expect(city).to(
          have_attributes(
            code: 12_025,
            city: '函館市',
            city_k: 'ハコダテシ',
            city_r: 'Hakodate-shi',
            point: [140.729108, 41.768712],
            county: nil,
            county_k: nil,
            county_r: nil,
            ward: nil,
            ward_k: nil,
            ward_r: nil
          )
        )
      end
    end

    context 'with a county city' do
      subject(:city) do
        described_class.from_json(
          'code' => 13_030,
          'county' => '石狩郡',
          'county_k' => 'イシカリグン',
          'county_r' => 'Ishikari-gun',
          'city' => '当別町',
          'city_k' => 'トウベツチョウ',
          'city_r' => 'Tobetsu-cho',
          'point' => [141.5170027, 43.22363701]
        )
      end

      it 'retains the county fields' do
        expect(city).to(have_attributes(county: '石狩郡', county_k: 'イシカリグン', county_r: 'Ishikari-gun'))
      end
    end
  end

  describe '#city_name' do
    it 'returns just the city for a plain city' do
      city = described_class.from_json('city' => '函館市')
      expect(city.city_name).to(eq('函館市'))
    end

    it 'prepends the county (JS cityName: county + city + ward)' do
      city = described_class.from_json('county' => '石狩郡', 'city' => '当別町')
      expect(city.city_name).to(eq('石狩郡当別町'))
    end

    it 'appends the ward for an ordinance-designated city' do
      city = described_class.from_json('city' => '札幌市', 'ward' => '中央区')
      expect(city.city_name).to(eq('札幌市中央区'))
    end
  end
end
