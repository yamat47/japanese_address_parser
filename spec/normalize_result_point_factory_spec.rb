# frozen_string_literal: true

require 'japanese_address_parser/normalize_result_point'

::RSpec.describe(::JapaneseAddressParser::NormalizeResultPoint) do
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

  describe '.normalize_result_point?' do
    it 'is true for a point with numeric lat/lng and a valid level' do
      [1, 2, 3, 8].each do |level|
        expect(described_class.normalize_result_point?(described_class.new(lat: 35.0, lng: 139.0, level:))).to(be(true))
      end
    end

    it 'is false for an invalid level' do
      expect(described_class.normalize_result_point?(described_class.new(lat: 35.0, lng: 139.0, level: 4))).to(be(false))
      expect(described_class.normalize_result_point?(described_class.new(lat: 35.0, lng: 139.0, level: 0))).to(be(false))
    end

    it 'is false for objects that do not respond to lat/lng/level' do
      expect(described_class.normalize_result_point?(nil)).to(be(false))
      expect(described_class.normalize_result_point?('35.0')).to(be(false))
      # JS↔Ruby のオブジェクトモデル差: JS はプロパティで見るが Ruby はメソッド応答で見るため
      # Hash（[]アクセス）は対象外（working_agreement §3-4）。
      expect(described_class.normalize_result_point?({ lat: 35.0, lng: 139.0, level: 3 })).to(be(false))
    end

    it 'is false when a coordinate is non-numeric' do
      expect(described_class.normalize_result_point?(described_class.new(lat: '35.0', lng: 139.0, level: 3))).to(be(false))
    end
  end
end
