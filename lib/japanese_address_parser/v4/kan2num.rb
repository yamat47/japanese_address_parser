# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/lib/kan2num.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

require 'japanese_address_parser/v4/japanese_numeral'

module JapaneseAddressParser
  module V4
    # 文字列中の漢数字を算用数字へ置換する。
    module Kan2num
      module_function

      # JS:
      #   const kanjiNumbers = findKanjiNumbers(string)
      #   for (...) { try { string = string.replace(kanjiNumbers[i], kanji2number(kanjiNumbers[i])) } catch { /* ignore */ } }
      #
      # 逐語移植上の要点:
      #   - JS の String.prototype.replace(searchString, ...) は最初の 1 件のみ置換するので
      #     Ruby は gsub ではなく sub を使う。
      #   - kanji2number は TypeError を投げうる。JS の try/catch に合わせて rescue で握り潰す。
      #     置換値は数値なので to_s で文字列化する。
      def call(string)
        kanji_numbers = JapaneseNumeral.find_kanji_numbers(string)
        kanji_numbers.each do |kanji_number|
          string = string.sub(kanji_number, JapaneseNumeral.kanji2number(kanji_number).to_s)
        rescue ::StandardError
          # ignore
        end

        string
      end
    end
    public_constant :Kan2num
  end
end
