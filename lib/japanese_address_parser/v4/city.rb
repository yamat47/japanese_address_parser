# frozen_string_literal: true

# Rich value object exposed by the v4 public API (M6).
# Ruby-original enrichment layer over the faithful NormalizeResult (working_agreement §1-3).
# 供給元: NormalizeResult#metadata.city（SingleCity VO）。

require 'japanese_address_parser/v4/normalize_result_point'

module JapaneseAddressParser
  module V4
    # 市区町村のリッチ VO。name は cityName（郡＋市＋政令区）。point は代表点（NormalizeResultPoint, level 2）。
    City =
      ::Data.define(:name, :code, :county, :ward, :name_kana, :name_romaji, :point) do
        # metadata.city（SingleCity VO）から VO を作る。city 未判別なら nil。
        def self.from_metadata(city)
          return if city.nil?

          new(name: city.city_name, code: city.code, county: city.county, ward: city.ward, name_kana: city.city_k, name_romaji: city.city_r, point: ResultPoint.city_to_result_point(city))
        end

        # 緯度経度をネストも含めて Hash 化する Ruby 独自 API。
        def to_h
          { name:, code:, county:, ward:, name_kana:, name_romaji:, point: point.to_h }
        end
      end
    public_constant :City
  end
end
