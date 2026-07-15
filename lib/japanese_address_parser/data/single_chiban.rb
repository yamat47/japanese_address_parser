# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

module JapaneseAddressParser
  module Data
    # SingleChiban — 地番（地番1・地番2・地番3）。M8 で CSV 行から生成する。
    SingleChiban =
      ::Data.define(:prc_num1, :prc_num2, :prc_num3, :point) do
        # JS: chibanToString(chiban) => [prc_num1, prc_num2, prc_num3].filter(Boolean).join('-')
        # JS の filter(Boolean) は falsy（nil・空文字）を除外する。Ruby では空文字は truthy なので
        # compact だけでは不十分。nil と空文字の両方を除外して忠実に再現する。
        def chiban_to_string
          [prc_num1, prc_num2, prc_num3]
            .reject { |value| value.nil? || value == '' }
            .join('-')
        end

        # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
        def self.from_json(hash)
          new(prc_num1: hash['prc_num1'], prc_num2: hash['prc_num2'], prc_num3: hash['prc_num3'], point: hash['point'])
        end
      end
    public_constant :SingleChiban
  end
end
