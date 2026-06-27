# frozen_string_literal: true

require 'japanese_address_parser/v4/normalize_result_point'

::RSpec.describe(::JapaneseAddressParser::V4::NormalizeResultPoint) do
  describe '.from_lng_lat' do
    it 'builds a point from a [lng, lat] array with the given level' do
      point = described_class.from_lng_lat([139.6, 35.5], level: 3)

      expect(point.lat).to(eq(35.5))
      expect(point.lng).to(eq(139.6))
      expect(point.level).to(eq(3))
    end

    it 'returns nil when the point array is nil' do
      expect(described_class.from_lng_lat(nil, level: 3)).to(be_nil)
    end
  end
end
