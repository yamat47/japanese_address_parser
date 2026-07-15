# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

module JapaneseAddressParser
  module Data
    # SingleRsdt — 住居表示住所（街区符号・住居番号・住居番号2）。M8 で CSV 行から生成する。
    SingleRsdt =
      ::Data.define(:blk_num, :rsdt_num, :rsdt_num2, :point) do
        # JS: rsdtToString(rsdt) => [blk_num, rsdt_num, rsdt_num2].filter(Boolean).join('-')
        # JS の filter(Boolean) は falsy（nil・空文字）を除外する。Ruby では空文字は truthy なので
        # compact だけでは不十分。nil と空文字の両方を除外して忠実に再現する。
        def rsdt_to_string
          [blk_num, rsdt_num, rsdt_num2]
            .reject { |value| value.nil? || value == '' }
            .join('-')
        end

        # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
        def self.from_json(hash)
          new(blk_num: hash['blk_num'], rsdt_num: hash['rsdt_num'], rsdt_num2: hash['rsdt_num2'], point: hash['point'])
        end
      end
    public_constant :SingleRsdt
  end
end
