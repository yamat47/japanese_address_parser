# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # Unicode正規化形式C（NFC）を適用するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/normalize.ts から移植
        # 結合文字を含む文字列を正規化形式Cに統一
        module NfcNormalizer
          # 文字列をNFC形式に正規化する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] NFC形式に正規化した文字列
          #
          # @example
          #   normalize("か\u3099") # => "が"
          #   normalize("ｶﾞｷﾞｸﾞ") # => "ガギグ"
          def normalize(str)
            return '' if str.nil?

            # 半角カタカナの対応表
            mapping = {
              'ｦ' => 'ヲ',
              'ｧ' => 'ァ',
              'ｨ' => 'ィ',
              'ｩ' => 'ゥ',
              'ｪ' => 'ェ',
              'ｫ' => 'ォ',
              'ｬ' => 'ャ',
              'ｭ' => 'ュ',
              'ｮ' => 'ョ',
              'ｯ' => 'ッ',
              'ｰ' => 'ー',
              'ｱ' => 'ア',
              'ｲ' => 'イ',
              'ｳ' => 'ウ',
              'ｴ' => 'エ',
              'ｵ' => 'オ',
              'ｶ' => 'カ',
              'ｷ' => 'キ',
              'ｸ' => 'ク',
              'ｹ' => 'ケ',
              'ｺ' => 'コ',
              'ｻ' => 'サ',
              'ｼ' => 'シ',
              'ｽ' => 'ス',
              'ｾ' => 'セ',
              'ｿ' => 'ソ',
              'ﾀ' => 'タ',
              'ﾁ' => 'チ',
              'ﾂ' => 'ツ',
              'ﾃ' => 'テ',
              'ﾄ' => 'ト',
              'ﾅ' => 'ナ',
              'ﾆ' => 'ニ',
              'ﾇ' => 'ヌ',
              'ﾈ' => 'ネ',
              'ﾉ' => 'ノ',
              'ﾊ' => 'ハ',
              'ﾋ' => 'ヒ',
              'ﾌ' => 'フ',
              'ﾍ' => 'ヘ',
              'ﾎ' => 'ホ',
              'ﾏ' => 'マ',
              'ﾐ' => 'ミ',
              'ﾑ' => 'ム',
              'ﾒ' => 'メ',
              'ﾓ' => 'モ',
              'ﾔ' => 'ヤ',
              'ﾕ' => 'ユ',
              'ﾖ' => 'ヨ',
              'ﾗ' => 'ラ',
              'ﾘ' => 'リ',
              'ﾙ' => 'ル',
              'ﾚ' => 'レ',
              'ﾛ' => 'ロ',
              'ﾜ' => 'ワ',
              'ﾝ' => 'ン',
              'ﾞ' => '゛',
              'ﾟ' => '゜'
            }

            result = str.dup
            mapping.each do |from, to|
              result = result.gsub(from, to)
            end

            # Unicode正規化（NFCへ変換）
            result.unicode_normalize(:nfc)
          end

          module_function :normalize
        end
      end
    end
  end
end
