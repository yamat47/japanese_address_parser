# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/src/index.ts
#          https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/src/utils.ts
#          https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/src/japaneseNumerics.ts
#          https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/src/oldJapaneseNumerics.ts
# Upstream: @geolonia/japanese-numeral v1.0.2
#           （@geolonia/normalize-japanese-addresses v3.1.3 が依存する外部 npm。
#             将来の gem 化に備え kan2num から使う 3 関数を単一モジュールへ内製移植する。）

module JapaneseAddressParser
  module V4
    # 漢数字 ⇔ 数値の相互変換。kanji2number / number2kanji / find_kanji_numbers を公開する。
    module JapaneseNumeral
      # src/japaneseNumerics.ts。挿入順を保持する（number2kanji / n2kan が keys[n] で
      # 数字 n に対応する漢字を引くため、〇..九 が先頭 10 要素である必要がある）。
      JAPANESE_NUMERICS = {
        '〇' => 0,
        '一' => 1,
        '二' => 2,
        '三' => 3,
        '四' => 4,
        '五' => 5,
        '六' => 6,
        '七' => 7,
        '八' => 8,
        '九' => 9,
        '０' => 0,
        '１' => 1,
        '２' => 2,
        '３' => 3,
        '４' => 4,
        '５' => 5,
        '６' => 6,
        '７' => 7,
        '８' => 8,
        '９' => 9
      }.freeze

      # src/oldJapaneseNumerics.ts。旧字体・異体字を新字体へ正規化する対応表。
      OLD_JAPANESE_NUMERICS = {
        '零' => '〇',
        '壱' => '一',
        '壹' => '一',
        '弐' => '二',
        '弍' => '二',
        '貳' => '二',
        '貮' => '二',
        '参' => '三',
        '參' => '三',
        '肆' => '四',
        '伍' => '五',
        '陸' => '六',
        '漆' => '七',
        '捌' => '八',
        '玖' => '九',
        '拾' => '十',
        '廿' => '二十',
        '陌' => '百',
        '佰' => '百',
        '阡' => '千',
        '仟' => '千',
        '萬' => '万'
      }.freeze

      # src/utils.ts。挿入順を保持する（変換は大きい単位から順に処理する）。
      LARGE_NUMBERS = { '兆' => 1_000_000_000_000, '億' => 100_000_000, '万' => 10_000 }.freeze
      SMALL_NUMBERS = { '千' => 1000, '百' => 100, '十' => 10 }.freeze

      private_constant :JAPANESE_NUMERICS
      private_constant :OLD_JAPANESE_NUMERICS
      private_constant :LARGE_NUMBERS
      private_constant :SMALL_NUMBERS

      module_function

      # JS: kanji2number(japanese) — src/index.ts
      def kanji2number(japanese)
        japanese = normalize(japanese)

        if japanese.match?(/〇/) || japanese.match?(/^[〇一二三四五六七八九]+$/)
          JAPANESE_NUMERICS.each do |key, value|
            reg = ::Regexp.new(key)
            japanese = japanese.gsub(reg, value.to_s)
          end

          js_number(japanese)
        else
          # numbers の値は NaN になりうる（untyped）ので number も untyped で受ける。
          # @type var number: untyped
          number = 0
          numbers = split_large_number(japanese)

          # 万以上の数字を数値に変換
          LARGE_NUMBERS.each do |key, value|
            next unless js_truthy?(numbers[key])

            number += value * numbers[key]
          end

          raise(::TypeError, 'The attribute of kanji2number() must be a Japanese numeral as integer.') unless number.is_a?(::Integer) && numbers['千'].is_a?(::Integer)

          # 千以下の数字を足す
          number + numbers['千']
        end
      end

      # JS: number2kanji(num) — src/index.ts
      def number2kanji(num)
        raise(::TypeError, 'The attribute of number2kanji() must be integer.') unless num.to_s.match?(/^[0-9]+$/)

        number = num
        kanji = ''

        # 万以上の数字を漢字に変換
        LARGE_NUMBERS.each do |key, value|
          n = number / value # JS: Math.floor(number / value)
          if js_truthy?(n)
            number -= n * value
            kanji = "#{kanji}#{n2kan(n)}#{key}"
          end
        end

        kanji = "#{kanji}#{n2kan(number)}" if js_truthy?(number)

        kanji.empty? ? '〇' : kanji # JS: kanji || '〇'
      end

      # JS: findKanjiNumbers(text) — src/index.ts
      def find_kanji_numbers(text)
        num = '([0-9０-９]*)|([〇一二三四五六七八九壱壹弐弍貳貮参參肆伍陸漆捌玖]*)'
        base_pattern = "((#{num})(千|阡|仟))?((#{num})(百|陌|佰))?((#{num})(十|拾))?(#{num})?"
        pattern = "((#{base_pattern}兆)?(#{base_pattern}億)?(#{base_pattern}(万|萬))?#{base_pattern})"

        matches = ecmascript_global_match(text, pattern)

        matches.select do |item|
          !item.match?(/^[0-9０-９]+$/) && !item.empty? && item != '兆' && item != '億' && item != '万' && item != '萬'
        end
      end

      # JS の String.prototype.match(text, /.../g) を Onigmo 上で再現するための内製マッチャ。
      #
      # find_kanji_numbers の正規表現は全グループが optional で「空文字」にもマッチしうる。
      # この種のパターンでは V8 と Onigmo の貪欲マッチ挙動が分岐する（working_agreement §3-4 /
      # 設計書 §9.3 の JS↔Onigmo 差異）:
      #   - V8 は各開始位置で（バックトラックの結果）最長マッチを返す。例えば "一" は "一"。
      #   - Onigmo は選択肢 `([0-9０-９]*)|([〇一…]*)` の先頭（空マッチ）で停止し、"一" を
      #     空マッチとして読み飛ばす。
      # 正規表現「文字列」は逐語のまま（§3-1）、マッチ「手続き」だけを V8 互換にする。
      # 各位置で「両端アンカー（\A…\z）でパターンが全消費する最長部分文字列」を採用すると
      # V8 の出力を再現できる（上流テストベクタ全件で一致を確認済み）。空マッチ時は 1 文字
      # 進める（ECMAScript の lastIndex 前進と同じ）。
      def ecmascript_global_match(text, pattern)
        anchored = ::Regexp.new("\\A(?:#{pattern})\\z")
        matches = []
        position = 0
        while position <= text.length
          longest = ''
          stop = text.length
          while stop > position
            candidate = text[position...stop]
            break unless candidate

            if anchored.match?(candidate)
              longest = candidate
              break
            end
            stop -= 1
          end
          matches << longest
          position += longest.empty? ? 1 : longest.length
        end
        matches
      end

      # --- 以下は src/utils.ts のヘルパ（外部には公開しない） ---

      # JS: normalize(japanese) — 旧字体を新字体へ置換
      def normalize(japanese)
        OLD_JAPANESE_NUMERICS.each do |key, value|
          reg = ::Regexp.new(key)
          japanese = japanese.gsub(reg, value)
        end
        japanese
      end

      # JS: splitLargeNumber(japanese) — 漢数字を兆・億・万単位に分割する
      def split_large_number(japanese)
        kanji = japanese
        numbers = {}
        LARGE_NUMBERS.each_key do |key|
          match = kanji.match(::Regexp.new("(.+)#{key}"))
          if match
            numbers[key] = kan2n(match[1])
            kanji = kanji.sub(match[0], '')
          else
            numbers[key] = 0
          end
        end

        numbers['千'] = kanji.empty? ? 0 : kan2n(kanji)
        numbers
      end

      # JS: kan2n(japanese) — 千単位以下の漢数字を数値へ（例: 三千 => 3000）
      def kan2n(japanese)
        return Integer(japanese, 10) if japanese.match?(/^[0-9]+$/) # JS: Number(japanese)

        kanji = zen2han(japanese)
        number = 0
        SMALL_NUMBERS.each do |key, value|
          match = kanji.match(::Regexp.new("(.*)#{key}"))
          next unless match

          n = 1
          if js_truthy?(match[1]) # JS: if (match[1]) — 空文字は falsy
            n =
              if match[1].match?(/^[0-9]+$/)
                Integer(match[1], 10)
              else
                JAPANESE_NUMERICS[match[1]] || ::Float::NAN # JS: undefined を掛けると NaN
              end
          end

          number += n * value
          kanji = kanji.sub(match[0], '')
        end

        unless kanji.empty?
          if kanji.match?(/^[0-9]+$/)
            number += Integer(kanji, 10)
          else
            kanji.each_char.with_index do |char, index|
              digit = kanji.length - index - 1
              number += (JAPANESE_NUMERICS[char] || ::Float::NAN) * (10**digit)
            end
          end
        end

        number
      end

      # JS: n2kan(num) — 10000 未満の数値を漢字へ
      def n2kan(num)
        kanji_numbers = JAPANESE_NUMERICS.keys
        number = num
        kanji = ''
        SMALL_NUMBERS.each do |key, value|
          n = number / value # JS: Math.floor(number / value)
          next unless js_truthy?(n)

          number -= n * value
          kanji =
            if n == 1
              "#{kanji}#{key}"
            else
              "#{kanji}#{kanji_numbers[n]}#{key}"
            end
        end

        kanji = "#{kanji}#{kanji_numbers[number]}" if js_truthy?(number)
        kanji
      end

      # JS: zen2han(str) — 全角数字のみを半角へ（utils.ts のローカル版。英字は対象外）
      def zen2han(str)
        str.gsub(/[０-９]/) { |s| (s.ord - 0xFEE0).chr(::Encoding::UTF_8) }
      end

      # JS の Number() のうち本モジュールで使う範囲（10 進整数文字列・空文字・不正値）を再現する。
      def js_number(str)
        return 0 if str.empty? # JS: Number('') === 0
        return Integer(str, 10) if str.match?(/^[0-9]+$/)

        ::Float::NAN
      end

      # JS の falsy 判定のうち本モジュールで使う範囲（nil / 0 / NaN / 空文字）を再現する。
      def js_truthy?(value)
        return false if value.nil?
        return false if value == 0
        return false if value.is_a?(::Float) && value.nan?
        return false if value == ''

        true
      end

      private_class_method :ecmascript_global_match, :normalize, :split_large_number, :kan2n, :n2kan, :zen2han, :js_number, :js_truthy?
    end
    public_constant :JapaneseNumeral
  end
end
