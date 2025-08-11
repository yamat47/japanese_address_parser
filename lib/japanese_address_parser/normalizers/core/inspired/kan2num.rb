# frozen_string_literal: true

module JapaneseAddressParser
  module Normalizers
    module Core
      module Inspired
        # 漢数字をアラビア数字に変換するモジュール
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/kan2num.ts および @geolonia/japanese-numeral から移植
        # 住所表記で頻出する漢数字をアラビア数字に変換
        module Kan2num
          # 文字列内の漢数字をアラビア数字に変換する
          #
          # @param str [String, nil] 変換対象の文字列
          # @return [String] 漢数字をアラビア数字に変換した文字列
          #
          # @example
          #   normalize('三丁目') # => "3丁目"
          #   normalize('十五番地') # => "15番地"
          def normalize(str)
            return '' if str.nil?

            result = str.dup

            # 有効な漢数字パターンを探して変換
            kanji_patterns = find_kanji_numbers(result)
            kanji_patterns.each do |pattern|
              number = convert_kanji_to_number(pattern)
              result = result.sub(pattern, number.to_s) if number
            end

            result
          end

          module_function :normalize

          private

          # 有効な漢数字パターンを検出
          # @param text [String] 検索対象の文字列
          # @return [Array<String>] 検出された漢数字パターンの配列

          def find_kanji_numbers(text)
            patterns = []

            # スキャン開始位置
            pos = 0
            while pos < text.length
              # 現在位置から漢数字の可能性がある文字列を探す
              if text[pos] =~ /[〇一二三四五六七八九千百十]/
                # マッチする最長のパターンを探す
                match_found = false
                best_pattern = nil
                best_length = 0

                # パターン1: 位取り表記（千百十を含む）
                # 千二百三十四、百二十三、二十三、十五、千、百、十など
                if text[pos..] =~ /^((?:[一二三四五六七八九]?千)?(?:[一二三四五六七八九]?百)?(?:[一二三四五六七八九]?十)?(?:[一二三四五六七八九])?)/
                  candidate = ::Regexp.last_match[1]
                  # 「千代」「千葉」「三重」のような地名パターンを除外
                  # 位取り記号を含む場合は位取りパターンとして扱う
                  next_char = pos + candidate.length < text.length ? text[pos + candidate.length] : nil
                  is_place_name = (candidate == '千' && next_char && next_char =~ /[代葉]/) ||
                                  (candidate == '三' && next_char && next_char == '重') ||
                                  (candidate == '八' && next_char && next_char == '王')
                  
                  if candidate && !candidate.empty? && !is_place_name &&
                     (candidate =~ /[千百十]/ && candidate.length > best_length)
                    best_pattern = candidate
                    best_length = candidate.length
                  end
                end

                # パターン2: 連続する単純な漢数字（〇を含む）
                # 二〇二三、一二三など
                if text[pos..] =~ /^([〇一二三四五六七八九]+)/
                  candidate = ::Regexp.last_match[1]
                  # 地名パターンのチェック
                  next_char = pos + candidate.length < text.length ? text[pos + candidate.length] : nil
                  is_place_name = (candidate == '千' && next_char && next_char =~ /[代葉]/) ||
                                  (candidate == '三' && next_char && next_char == '重') ||
                                  (candidate == '八' && next_char && next_char == '王')
                  
                  # 〇を含む場合、または位取り記号を含まない場合は単純パターンとして扱う
                  if !is_place_name && (candidate =~ /〇/ || candidate !~ /[千百十]/) && candidate.length > best_length
                    best_pattern = candidate
                    best_length = candidate.length
                  end
                end

                # 最適なパターンを追加
                if best_pattern && !place_name_context?(text, pos, best_pattern)
                  patterns << best_pattern
                  pos += best_pattern.length
                  match_found = true
                end

                pos += 1 unless match_found
              else
                pos += 1
              end
            end

            patterns
          end

          # 地名の文脈で漢数字変換を避けるべきかチェック
          # @param text [String] 全体のテキスト
          # @param pos [Integer] パターンの開始位置
          # @param pattern [String] 変換候補のパターン
          # @return [Boolean] 地名の文脈で変換を避けるべきならtrue
          def place_name_context?(text, pos, pattern)
            # "三芳" のような地名を保護
            return true if pattern == '三' && pos + 1 < text.length && text[pos + 1] == '芳'

            false
          end

          module_function :place_name_context?

          # 漢数字パターンを数値に変換
          # @param pattern [String] 漢数字パターン
          # @return [Integer, nil] 変換後の数値

          def convert_kanji_to_number(pattern)
            return if pattern.nil? || pattern.empty?

            # 冗長な表記の処理
            pattern = pattern.gsub(/一千/, '千').gsub(/一百/, '百').gsub(/一十/, '十')

            # 位取り表記の場合
            if pattern =~ /[千百十]/
              value = 0

              # 千の処理
              if pattern =~ /([一二三四五六七八九]?)千/
                digit = ::Regexp.last_match[1].empty? ? 1 : kanji_digit(::Regexp.last_match[1])
                value += digit * 1000
                pattern = pattern.sub(/[一二三四五六七八九]?千/, '')
              end

              # 百の処理
              if pattern =~ /([一二三四五六七八九]?)百/
                digit = ::Regexp.last_match[1].empty? ? 1 : kanji_digit(::Regexp.last_match[1])
                value += digit * 100
                pattern = pattern.sub(/[一二三四五六七八九]?百/, '')
              end

              # 十の処理
              if pattern =~ /([一二三四五六七八九]?)十/
                digit = ::Regexp.last_match[1].empty? ? 1 : kanji_digit(::Regexp.last_match[1])
                value += digit * 10
                pattern = pattern.sub(/[一二三四五六七八九]?十/, '')
              end

              # 一の位の処理
              value += kanji_digit(pattern) if !pattern.empty? && pattern =~ /^[一二三四五六七八九]$/

              value
            elsif pattern =~ /^[〇一二三四五六七八九]+$/
              # 単純な漢数字の連続（〇を含む）
              pattern.chars.map { |c| kanji_digit(c) }
                     .join.to_i
            end
          end

          # 単一の漢数字を数値に変換
          # @param kanji [String] 漢数字（1文字）
          # @return [Integer] 対応する数値

          def kanji_digit(kanji)
            digits = { '〇' => 0, '一' => 1, '二' => 2, '三' => 3, '四' => 4, '五' => 5, '六' => 6, '七' => 7, '八' => 8, '九' => 9 }
            digits[kanji] || 0
          end

          module_function :find_kanji_numbers, :convert_kanji_to_number, :kanji_digit
          private_class_method :find_kanji_numbers, :convert_kanji_to_number, :kanji_digit
        end
      end
    end
  end
end
