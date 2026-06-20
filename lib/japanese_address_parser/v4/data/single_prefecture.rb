# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

require_relative 'single_city'

module JapaneseAddressParser
  module V4
    module Data
      # SinglePrefecture — api/ja.json の data 要素（都道府県＋配下の市区町村一覧）。
      SinglePrefecture =
        ::Data.define(:code, :pref, :pref_k, :pref_r, :point, :cities) do
          # JS: prefectureName(pref) => pref.pref
          def prefecture_name
            pref
          end

          # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
          def self.from_json(hash)
            cities = (hash['cities'] || []).map { |city| ::JapaneseAddressParser::V4::Data::SingleCity.from_json(city) }
            new(code: hash['code'], pref: hash['pref'], pref_k: hash['pref_k'], pref_r: hash['pref_r'], point: hash['point'], cities: cities)
          end
        end
      public_constant :SinglePrefecture
    end
  end
end
