# frozen_string_literal: true

require 'japanese_address_parser/normalize_result_point'
require 'japanese_address_parser/data/single_prefecture'
require 'japanese_address_parser/data/single_city'
require 'japanese_address_parser/data/single_machi_aza'

::RSpec.describe(::JapaneseAddressParser::ResultPoint) do
  # point は [lng, lat]。NormalizeResultPoint は lat/lng/level を持つ（level は座標の正確さ）。
  describe '.prefecture_to_result_point' do
    it 'maps pref.point [lng, lat] to lat/lng with level 1' do
      pref = ::JapaneseAddressParser::Data::SinglePrefecture.from_json('point' => [139.5, 35.6])
      point = described_class.prefecture_to_result_point(pref)

      expect(point.lng).to(eq(139.5))
      expect(point.lat).to(eq(35.6))
      expect(point.level).to(eq(1))
    end
  end

  describe '.city_to_result_point' do
    it 'maps city.point to lat/lng with level 2' do
      city = ::JapaneseAddressParser::Data::SingleCity.from_json('point' => [139.7, 35.4])
      point = described_class.city_to_result_point(city)

      expect(point.lat).to(eq(35.4))
      expect(point.level).to(eq(2))
    end
  end

  describe '.machi_aza_to_result_point' do
    it 'maps machi_aza.point to lat/lng with level 3' do
      machi_aza = ::JapaneseAddressParser::Data::SingleMachiAza.from_json('point' => [139.6, 35.5])

      expect(described_class.machi_aza_to_result_point(machi_aza).level).to(eq(3))
    end

    it 'returns nil when the machi_aza has no point' do
      machi_aza = ::JapaneseAddressParser::Data::SingleMachiAza.from_json({})

      expect(described_class.machi_aza_to_result_point(machi_aza)).to(be_nil)
    end
  end

  describe '.upgrade_point' do
    let(:level1) { ::JapaneseAddressParser::NormalizeResultPoint.new(lat: 1.0, lng: 1.0, level: 1) }
    let(:level3) { ::JapaneseAddressParser::NormalizeResultPoint.new(lat: 3.0, lng: 3.0, level: 3) }

    it 'returns b when a is nil' do
      expect(described_class.upgrade_point(nil, level1)).to(be(level1))
    end

    it 'returns a when b is nil' do
      expect(described_class.upgrade_point(level1, nil)).to(be(level1))
    end

    it 'keeps the higher-level (more accurate) point' do
      expect(described_class.upgrade_point(level3, level1)).to(be(level3))
      expect(described_class.upgrade_point(level1, level3)).to(be(level3))
    end
  end
end
