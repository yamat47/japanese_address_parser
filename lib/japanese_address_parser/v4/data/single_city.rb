# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

module JapaneseAddressParser
  module V4
    module Data
      # SingleCity — api/ja.json の cities 要素（政令市の場合は区で区切られる）。
      # `::Data.define`（先頭 `::` は名前空間 JapaneseAddressParser::V4::Data 内で
      # トップレベル定数 ::Data を指すために必須）。
      SingleCity =
        ::Data.define(:code, :county, :county_k, :county_r, :city, :city_k, :city_r, :ward, :ward_k, :ward_r, :point) do
          # JS: cityName(city) => `${city.county || ''}${city.city}${city.ward || ''}`
          # nil の補間は Ruby では空文字になるため `|| ''` 相当。
          def city_name
            "#{county}#{city}#{ward}"
          end

          # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
          def self.from_json(hash)
            new(
              code: hash['code'],
              county: hash['county'],
              county_k: hash['county_k'],
              county_r: hash['county_r'],
              city: hash['city'],
              city_k: hash['city_k'],
              city_r: hash['city_r'],
              ward: hash['ward'],
              ward_k: hash['ward_k'],
              ward_r: hash['ward_r'],
              point: hash['point']
            )
          end
        end
      public_constant :SingleCity
    end
  end
end
