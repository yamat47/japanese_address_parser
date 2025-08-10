# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 数字に隣接するハイフン類を統一するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/normalize.ts から移植
        # 数字の前後にある様々なハイフン・ダッシュ・長音記号を標準のハイフンに統一
        module HyphenNormalizer
          # 数字に隣接するハイフン類を統一する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] ハイフンを正規化した文字列
          #
          # @example
          #   normalize('1－2－3') # => "1-2-3"
          #   normalize('東京都港区芝１ー２ー３') # => "東京都港区芝１-２-３"
          def normalize(str)
            return '' if str.nil?

            # 変換対象のハイフン類
            # 全角ハイフン、マイナス記号、各種ダッシュ、長音記号など
            hyphen_chars = '[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]'

            # 数字のパターン
            # 半角数字、全角数字、漢数字、〇、十百千
            number_chars = '[0-9０-９一二三四五六七八九〇十百千]'

            # パターン1: 数字の後にハイフン類がある場合
            # パターン2: ハイフン類の後に数字がある場合
            pattern = /(#{number_chars}#{hyphen_chars})|(#{hyphen_chars}#{number_chars})/

            str.gsub(pattern) do |match|
              # マッチした部分のハイフン類をすべて標準のハイフンに置換
              match.gsub(/#{hyphen_chars}/, '-')
            end
          end

          module_function :normalize
        end
      end
    end
  end
end
