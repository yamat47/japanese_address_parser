# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 全角英数字を半角に変換するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/zen2han.ts から移植
        #
        # JavaScript実装:
        # export const zen2han = (str: string) => {
        #   return str.replace(/[Ａ-Ｚａ-ｚ０-９]/g, (s) => {
        #     return String.fromCharCode(s.charCodeAt(0) - 0xfee0)
        #   })
        # }
        module Zen2han
          # 文字列内の全角英数字を半角に変換する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] 全角英数字を半角に変換した文字列
          #
          # @example
          #   normalize('ＡＢＣ１２３') # => "ABC123"
          #   normalize('東京都港区１－２－３') # => "東京都港区1－2－3"
          def normalize(str)
            return '' if str.nil?

            # 全角・半角の差分（Unicode コードポイントの差）
            # 全角文字のコードポイントから0xFEE0を引くと対応する半角文字になる
            fullwidth_halfwidth_diff = 0xFEE0

            # 変換対象の正規表現パターン
            # - 全角大文字: U+FF21-U+FF3A (Ａ-Ｚ)
            # - 全角小文字: U+FF41-U+FF5A (ａ-ｚ)
            # - 全角数字: U+FF10-U+FF19 (０-９)
            fullwidth_alphanumeric_pattern = /[Ａ-Ｚａ-ｚ０-９]/

            str.gsub(fullwidth_alphanumeric_pattern) do |char|
              (char.ord - fullwidth_halfwidth_diff).chr
            end
          end

          module_function :normalize
        end
      end
    end
  end
end
