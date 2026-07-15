# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/dict.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

require 'japanese_address_parser/dictionaries/convert'

module JapaneseAddressParser
  # 住所文字列を表記ゆれを吸収する正規表現パターン文字列へ変換する。
  module Dict
    module_function

    # JS: toRegexPattern(string) — replace チェーンの順序をそのまま移植する。
    # 「なるべく文字数が多いものほど上にすること」という上流コメント順を保持する。
    # 置換文字列に $（JS 特殊）も \\（Ruby gsub 特殊）も含まれないため literal 置換になる。
    def to_regex_pattern(string)
      str = string
            .gsub(/三栄町|四谷三栄町/, '(三栄町|四谷三栄町)')
            .gsub(/鬮野川|くじ野川|くじの川/, '(鬮野川|くじ野川|くじの川)')
            .gsub(/柿碕町|柿さき町/, '(柿碕町|柿さき町)')
            .gsub(/通り|とおり/, '(通り|とおり)')
            .gsub(/埠頭|ふ頭/, '(埠頭|ふ頭)')
            .gsub(/番町|番丁/, '(番町|番丁)')
            .gsub(/大冝|大宜/, '(大冝|大宜)')
            .gsub(/穝|さい/, '(穝|さい)')
            .gsub(/杁|えぶり/, '(杁|えぶり)')
            .gsub(/薭|稗|ひえ|ヒエ/, '(薭|稗|ひえ|ヒエ)')
            .gsub(/[之ノの]/, '[之ノの]')
            .gsub(/[ヶケが]/, '[ヶケが]')
            .gsub(/[ヵカか力]/, '[ヵカか力]')
            .gsub(/[ッツっつ]/, '[ッツっつ]')
            .gsub(/[ニ二]/, '[ニ二]')
            .gsub(/[ハ八]/, '[ハ八]')
            .gsub(/塚|塚/, '(塚|塚)')
            .gsub(/釜|竈/, '(釜|竈)')
            .gsub(/條|条/, '(條|条)')
            .gsub(/狛|拍/, '(狛|拍)')
            .gsub(/藪|薮/, '(藪|薮)')
            .gsub(/渕|淵/, '(渕|淵)')
            .gsub(/エ|ヱ|え/, '(エ|ヱ|え)')
            .gsub(/曾|曽/, '(曾|曽)')
            .gsub(/舟|船/, '(舟|船)')
            .gsub(/莵|菟/, '(莵|菟)')
            .gsub(/市|巿/, '(市|巿)')
            .gsub(/崎|﨑/, '(崎|﨑)')

      Dictionaries::Convert.call(str)
    end
  end
  public_constant :Dict
end
