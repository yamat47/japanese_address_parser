# frozen_string_literal: true

require_relative 'kan2num'
require_relative 'zen2han'

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 町域マッチング後の住所文字列の後処理
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/normalize.ts の町域マッチング後の処理
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/normalize.ts#L428-L476
        module AddressPostprocessor
          # アラビア数字を漢数字に変換
          # @geolonia/japanese-numeral の number2kanji 相当
          def self.number_to_kanji(number)
            kanji_map = { 0 => '〇', 1 => '一', 2 => '二', 3 => '三', 4 => '四', 5 => '五', 6 => '六', 7 => '七', 8 => '八', 9 => '九' }

            result = ''
            num_str = number.to_s

            # 10以上の場合の処理
            if number >= 10
              if number < 20
                result = '十'
                result += kanji_map[number - 10] if number > 10
              elsif number < 100
                tens = number / 10
                result = kanji_map[tens] + '十'
                ones = number % 10
                result += kanji_map[ones] if ones > 0
              else
                # 100以上はそのまま各桁を変換
                num_str.each_char do |c|
                  result += kanji_map[c.to_i]
                end
              end
            else
              result = kanji_map[number]
            end

            result
          end

          # 町域マッチング後の住所文字列を処理
          #
          # @geolonia/normalize-japanese-addresses v2.10.0
          # src/normalize.ts#L430-L475
          def self.process(addr, has_town = false)
            return addr unless has_town

            addr
                     # 先頭のハイフンを削除
                     .gsub(/^-/, '')
                     # 数字+丁目を漢数字+丁目に変換
                     .gsub(/([0-9]+)(丁目)/) do |match|
                       num = match.match(/([0-9]+)/)[1]
                       "#{number_to_kanji(num.to_i)}丁目"
                     end
                     # 番地・号の処理 (パターン1: スペースで区切る)
                     .gsub(
                       /(([0-9]+|[〇一二三四五六七八九十百千]+)(番地?)([0-9]+|[〇一二三四五六七八九十百千]+)号)\s*(.+)/,
                       '\1 \5'
                     )
                     # 番地・号の処理 (パターン2: ハイフンでつなぐ)
                     .gsub(
                       /([0-9]+|[〇一二三四五六七八九十百千]+)\s*(番地?)\s*([0-9]+|[〇一二三四五六七八九十百千]+)\s*号?/,
                       '\1-\3'
                     )
                     # 番地を削除
                     .gsub(/([0-9]+|[〇一二三四五六七八九十百千]+)番地?/, '\1')
                     # 「の」をハイフンに変換
                     .gsub(/([0-9]+|[〇一二三四五六七八九十百千]+)の/, '\1-')
                     # 数字+横棒の処理
                     .gsub(/([0-9]+|[〇一二三四五六七八九十百千]+)[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/) do |match|
                       Kan2num.normalize(match).gsub(/[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/, '-')
                     end
                     # 横棒+数字の処理
                     .gsub(/[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]([0-9]+|[〇一二三四五六七八九十百千]+)/) do |match|
                       Kan2num.normalize(match).gsub(/[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/, '-')
                     end
                     # `1-` のようなケース
                     .gsub(/([0-9]+|[〇一二三四五六七八九十百千]+)-/) do |s|
                       Kan2num.normalize(s)
                     end
                     # `-1` のようなケース
                     .gsub(/-([0-9]+|[〇一二三四五六七八九十百千]+)/) do |s|
                       Kan2num.normalize(s)
                     end
                     # `-あ1` のようなケース
                     .gsub(/-[^0-9]([0-9]+|[〇一二三四五六七八九十百千]+)/) do |s|
                       Kan2num.normalize(Zen2han.normalize(s))
                     end
                     # 末尾の漢数字を変換
                     .gsub(/([0-9]+|[〇一二三四五六七八九十百千]+)$/) do |s|
                Kan2num.normalize(s)
            end
                     .strip
          end
        end
      end
    end
  end
end
