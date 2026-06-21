# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/dictionaries/convert.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

require 'japanese_address_parser/v4/dictionaries/dictionary'

module JapaneseAddressParser
  module V4
    module Dictionaries
      # 辞書の各文字を「旧字体・新字体の両方にマッチする」正規表現パターン文字列へ展開する。
      # 例: '亞' も '亜' も '(亞|亜)' に変換するので、後続の正規表現がどちらの字体にもマッチする。
      module Convert
        # JS:
        #   const patternMap = dictionary.reduce((acc, d) => {
        #     const pattern = `(${d.src}|${d.dst})`
        #     return { ...acc, [d.src]: pattern, [d.dst]: pattern }
        #   }, {})
        # 既存キーへの再代入は位置を保って値を更新する（JS object と Ruby Hash で同挙動）。
        pattern_map = {}
        Dictionary::DICTIONARY.each do |entry|
          pattern = "(#{entry[:src]}|#{entry[:dst]})"
          pattern_map[entry[:src]] = pattern
          pattern_map[entry[:dst]] = pattern
        end
        PATTERN_MAP = pattern_map.freeze

        # JS: new RegExp(Array.from(new Set(Object.values(patternMap))).join('|'), 'g')
        # Set による重複排除は uniq（出現順保持）で再現。'g' フラグは gsub が既定で全置換するため不要。
        REGEXP = ::Regexp.new(PATTERN_MAP.values.uniq.join('|'))

        private_constant :PATTERN_MAP
        private_constant :REGEXP

        module_function

        # JS: export const convert = (regexText) => regexText.replace(regexp, (match) => patternMap[match])
        def call(regex_text)
          regex_text.gsub(REGEXP) { |match| PATTERN_MAP[match] }
        end
      end
      public_constant :Convert
    end
  end
end
