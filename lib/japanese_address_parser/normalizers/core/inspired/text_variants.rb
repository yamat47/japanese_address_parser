# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 表記ゆらぎを吸収するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/dict.ts の toRegexPattern から移植
        # 住所表記で頻出する表記ゆらぎを統一形式に正規化
        module TextVariants
          # 文字列内の表記ゆらぎを統一形式に変換する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] 表記ゆらぎを統一した文字列
          #
          # @example
          #   normalize('霞ケ関') # => "霞ヶ関"
          #   normalize('一ツ橋') # => "一ツ橋"
          def normalize(str)
            return '' if str.nil?

            result = str.dup

            # 複合的な表記の統一（順序重要：文字数が多いものから処理）
            result = normalize_compound_variants(result)

            # 単一文字の表記ゆらぎ統一
            normalize_single_char_variants(result)
          end

          module_function :normalize

          private

          # 複合的な表記ゆらぎの統一
          # @param str [String] 変換対象の文字列
          # @return [String] 変換後の文字列
          def normalize_compound_variants(str)
            result = str.dup

            # 埠頭/ふ頭 → 埠頭
            result.gsub!(/ふ頭/, '埠頭')

            # 番町/番丁 → 番町
            result.gsub!(/番丁/, '番町')

            # 通り/とおり → 通り
            result.gsub!(/とおり/, '通り')

            # 塚の異体字（U+FA10） → 通常の塚（U+585A）
            result.gsub!(/塚/, '塚')

            # 釜/竈 → 釜
            result.gsub!(/竈/, '釜')

            # 條/条 → 条
            result.gsub!(/條/, '条')

            # 狛/拍 → 狛
            result.gsub!(/拍/, '狛')

            # 藪/薮 → 薮
            result.gsub!(/藪/, '薮')

            # 渕/淵 → 渕
            result.gsub!(/淵/, '渕')

            # 曾/曽 → 曽
            result.gsub!(/曾/, '曽')

            # 舟/船 → 舟
            result.gsub!(/船/, '舟')

            result
          end

          # 単一文字の表記ゆらぎ統一
          # @param str [String] 変換対象の文字列
          # @return [String] 変換後の文字列
          def normalize_single_char_variants(str)
            result = str.dup

            # ヶケが → ヶ（小書きカタカナ）
            # 例：霞ケ関 → 霞ヶ関、鳩ケ谷 → 鳩ヶ谷
            result.gsub!(/[ケが]/, 'ヶ')

            # ヵカか力 → ヶ（実際の住所ではヶが使われることが多い）
            # 例：一ヵ月 → 一ヶ月（住所では「ヶ所」「ヶ月」など）
            result.gsub!(/[ヵカか力]/, 'ヶ')

            # 之ノの → ノ（カタカナ）
            # 例：木之本 → 木ノ本
            result.gsub!(/[之の]/, 'ノ')

            # ッツっつ → ツ（カタカナ大文字）
            # 例：三ッ谷 → 三ツ谷
            result.gsub!(/[ッっつ]/, 'ツ')

            # ニ二 → 二（漢数字）
            # 例：ニ番町 → 二番町
            result.gsub!(/ニ/, '二')

            # ハ八 → 八（漢数字）
            # 例：ハ番地 → 八番地
            result.gsub!(/ハ/, '八')

            result
          end

          module_function :normalize_compound_variants, :normalize_single_char_variants
          private_class_method :normalize_compound_variants, :normalize_single_char_variants
        end
      end
    end
  end
end
