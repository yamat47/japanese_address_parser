# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # スペースを正規化するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/normalize.ts から移植
        # 全角スペースを半角スペースに変換し、連続するスペースを単一のスペースに圧縮
        module SpaceNormalizer
          # 文字列内のスペースを正規化する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] スペースを正規化した文字列
          #
          # @example
          #   normalize('東京都　港区　芝') # => "東京都 港区 芝"
          #   normalize('東京都  港区   芝') # => "東京都 港区 芝"
          def normalize(str)
            return '' if str.nil?

            str.gsub(/　/, ' ').gsub(/ +/, ' ')
          end

          module_function :normalize
        end
      end
    end
  end
end
