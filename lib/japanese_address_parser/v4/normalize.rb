# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/normalize.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   normalize（level 0-3、option.level <= 3 の早期 return まで）と normalizeTownName。
#   level 8（normalizeAddrPart）は M8 で追加する。公開 API（JapaneseAddressParser.call）化は M6。

require 'japanese_address_parser/v4/normalize_helpers'
require 'japanese_address_parser/v4/cache_regexes'
require 'japanese_address_parser/v4/patch_addr'
require 'japanese_address_parser/v4/kan2num'
require 'japanese_address_parser/v4/zen2han'
require 'japanese_address_parser/v4/japanese_numeral'
require 'japanese_address_parser/v4/utils'
require 'japanese_address_parser/v4/normalize_result'
require 'japanese_address_parser/v4/normalize_result_point'

module JapaneseAddressParser
  module V4
    # 住所文字列を都道府県・市区町村・町字・番地へ正規化する（level 0-3）。
    module Normalize
      # JS: defaultOption = { level: 8 }
      DEFAULT_LEVEL = 8

      # 番地正規化で使う「半角数字 or 漢数字」の交替（1 キャプチャグループ）。
      NUM = '([0-9]+|[〇一二三四五六七八九十百千]+)'
      # 数字に隣接する横棒（ハイフン・マイナス・長音記号・罫線等）の文字クラス（上流 normalize.ts と同一）。
      DASHES = '-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━'

      private_constant :DEFAULT_LEVEL
      private_constant :NUM
      private_constant :DASHES

      module_function

      # JS: normalize(address, option)
      def call(address, level: DEFAULT_LEVEL)
        other = NormalizeHelpers.prenormalize(address)

        # @type var pref: Data::SinglePrefecture?
        pref = nil
        # @type var city: Data::SingleCity?
        city = nil
        # @type var town: untyped
        town = nil
        # @type var point: NormalizeResultPoint?
        point = nil
        # @type var addr: String?
        addr = nil

        prefectures = CacheRegexes.get_prefectures
        api_version = prefectures.meta.updated
        pref_patterns = CacheRegexes.get_prefecture_regex_patterns(prefectures)
        same_named_patterns = CacheRegexes.get_same_named_prefecture_city_regex_patterns(prefectures)

        # 県名が省略されており市名がどこかの都道府県名と同じ場合（例: 千葉県千葉市）、県名を補完する。
        same_named_patterns.each do |prefecture_city, reg|
          regex = ::Regexp.new(reg)
          next unless other.match?(regex)

          other = other.sub(regex, prefecture_city) # JS: replace(new RegExp(reg), prefectureCity)（g 無し）
          break
        end

        # 都道府県名の正規化
        pref_patterns.each do |single_pref, pattern|
          match = other.match(::Regexp.new(pattern))
          next unless match

          pref = single_pref
          other = other[match[0].to_s.length..].to_s # 都道府県名以降の住所
          point = ResultPoint.prefecture_to_result_point(single_pref)
          break
        end

        unless pref
          # 都道府県名が省略されている。全都道府県の市区町村パターンから候補を集める。
          # @type var matched: Array[Hash[Symbol, untyped]]
          matched = []
          prefectures.data.each do |single_pref|
            city_patterns = CacheRegexes.get_city_regex_patterns(single_pref)
            other = other.strip
            city_patterns.each do |single_city, pattern|
              match = other.match(::Regexp.new(pattern))
              matched << { pref: single_pref, city: single_city, other: other[match[0].to_s.length..].to_s } if match
            end
          end

          if matched.length == 1
            pref = matched[0][:pref]
          else
            # 複数候補は町名まで正規化して判別する（例: 東京都府中市 と 広島県府中市）。
            matched.each do |candidate|
              normalized = normalize_town_name(candidate[:other], candidate[:pref], candidate[:city], api_version)
              next unless normalized

              pref = candidate[:pref]
              city = candidate[:city]
              town = normalized[:town]
              other = normalized[:other]
              point = ResultPoint.upgrade_point(point, ResultPoint.machi_aza_to_result_point(town))
            end
          end
        end

        if pref && level >= 2
          city_patterns = CacheRegexes.get_city_regex_patterns(pref)
          other = other.strip
          city_patterns.each do |single_city, pattern|
            match = other.match(::Regexp.new(pattern))
            next unless match

            city = single_city
            point = ResultPoint.upgrade_point(point, ResultPoint.city_to_result_point(single_city))
            other = other[match[0].to_s.length..].to_s # 市区町村名以降の住所
            break
          end
        end

        # 町丁目以降の正規化
        if pref && city && level >= 3
          normalized = normalize_town_name(other, pref, city, api_version)
          if normalized
            town = normalized[:town]
            other = normalized[:other]
            point = ResultPoint.upgrade_point(point, ResultPoint.machi_aza_to_result_point(town))
          end

          # town が取得できた場合にのみ、番地正規化を行う。
          other = normalize_addr(other) if town
        end

        other = PatchAddr.call(
          pref ? pref.prefecture_name : '',
          city ? city.city_name : '',
          town ? town.machi_aza_name : '',
          other
        )

        level_value = 0
        level_value += 1 if pref
        level_value += 1 if city
        level_value += 1 if town

        # JS: if (option.level <= 3 || level < 3) { return result }
        # metadata は VO に昇格しない生データの逃がし道（working_agreement §1-3）。
        if level <= 3 || level_value < 3
          return NormalizeResult.new(
            pref: pref ? pref.prefecture_name : nil,
            city: city ? city.city_name : nil,
            town: town ? town.machi_aza_name : nil,
            addr:,
            other:,
            point:,
            level: level_value,
            metadata: NormalizeResultMetadata.new(input: address, prefecture: Utils.remove_cities_from_prefecture(pref), city:, machi_aza: Utils.remove_extra_from_machi_aza(town), chiban: nil, rsdt: nil)
          )
        end

        # level 8（住居表示 rsdt / 地番 chiban）。ここに来るのは level_value == 3 かつ level >= 4 のとき。
        normalized_addr_part = normalize_addr_part(other, pref, city, town, api_version)
        # JS TODO: rsdt と地番を両方対応した時に両方返すけど、今は rsdt を優先する
        if normalized_addr_part[:rsdt]
          addr = normalized_addr_part[:rsdt].rsdt_to_string
          other = normalized_addr_part[:rest]
          point = ResultPoint.upgrade_point(point, ResultPoint.rsdt_or_chiban_to_result_point(normalized_addr_part[:rsdt]))
          level_value = 8
        elsif normalized_addr_part[:chiban]
          addr = normalized_addr_part[:chiban].chiban_to_string
          other = normalized_addr_part[:rest]
          point = ResultPoint.upgrade_point(point, ResultPoint.rsdt_or_chiban_to_result_point(normalized_addr_part[:chiban]))
          level_value = 8
        end

        NormalizeResult.new(
          pref: pref ? pref.prefecture_name : nil,
          city: city ? city.city_name : nil,
          town: town ? town.machi_aza_name : nil,
          addr:,
          other:,
          point:,
          level: level_value,
          metadata: NormalizeResultMetadata.new(
            input: address,
            prefecture: Utils.remove_cities_from_prefecture(pref),
            city:,
            machi_aza: Utils.remove_extra_from_machi_aza(town),
            chiban: normalized_addr_part[:chiban],
            rsdt: normalized_addr_part[:rsdt]
          )
        )
      end

      # JS: normalizeTownName(input, pref, city, apiVersion)
      def normalize_town_name(input, pref, city, api_version)
        input = input.strip.sub(/\A大字/, '') # JS: input.trim().replace(/^大字/, '')（^ → \A）
        town_patterns = CacheRegexes.get_town_regex_patterns(pref, city, api_version)

        regex_prefixes = ['\A'] # JS: ['^']（^ → \A）
        regex_prefixes.push('.*') if city.city == '京都市' # 京都は通り名削除のため後方一致

        regex_prefixes.each do |regex_prefix|
          town_patterns.each do |town, pattern|
            match = input.match(::Regexp.new("#{regex_prefix}#{pattern}"))
            return { town:, other: input[match[0].to_s.length..].to_s } if match
          end
        end

        nil
      end

      # JS: 「町丁目以降の正規化」の replace チェーン（番地正規化）。順序込み逐語移植。
      # /g の有無で gsub/sub を厳守し、$1 等は \1 に、^/$ は \A/\z に翻訳する。
      def normalize_addr(other)
        other
          .sub(/\A-/, '')
          .gsub(/([0-9]+)(丁目)/) { |match| match.gsub(/([0-9]+)/) { |num| JapaneseNumeral.number2kanji(Integer(num, 10)) } }
          .sub(/(#{NUM}(番地?)#{NUM}号)\s*(.+)/, '\1 \5')
          .sub(/#{NUM}\s*(番地?)\s*#{NUM}\s*号?/, '\1-\3')
          .sub(/#{NUM}番(地|\z)/, '\1')
          .gsub(/#{NUM}の/, '\1-')
          .gsub(/#{NUM}[#{DASHES}]/) { |match| Kan2num.call(match).gsub(/[#{DASHES}]/, '-') }
          .gsub(/[#{DASHES}]#{NUM}/) { |match| Kan2num.call(match).gsub(/[#{DASHES}]/, '-') }
          .sub(/#{NUM}-/) { |s| Kan2num.call(s) } # `1-` のようなケース
          .sub(/-#{NUM}/) { |s| Kan2num.call(s) } # `-1` のようなケース
          .sub(/-[^0-9]#{NUM}/) { |s| Kan2num.call(Zen2han.call(s)) } # `-あ1` のようなケース
          .sub(/#{NUM}\z/) { |s| Kan2num.call(s) } # `串本町串本１２３４` のようなケース
          .strip
      end

      # JS: normalizeAddrPart(addr, pref, city, town, apiVersion)
      def normalize_addr_part(addr, pref, city, town, api_version)
        # JS: /^([1-9][0-9]*)(?:-([1-9][0-9]*))?(?:-([1-9][0-9]*))?/（^ → \A）
        match = addr.match(/\A([1-9][0-9]*)(?:-([1-9][0-9]*))?(?:-([1-9][0-9]*))?/)
        return { rest: addr } unless match

        matched = match[0].to_s
        # JS TODO: rsdt の場合は rsdt と地番を両方取得する
        if town.rsdt
          CacheRegexes.get_rsdt(pref, city, town, api_version).each do |rsdt|
            addr_part = rsdt.rsdt_to_string
            return { rsdt:, rest: addr[addr_part.length..].to_s } if matched == addr_part
          end
        else
          CacheRegexes.get_chiban(pref, city, town, api_version).each do |chiban|
            addr_part = chiban.chiban_to_string
            return { chiban:, rest: addr[addr_part.length..].to_s } if matched == addr_part
          end
        end
        { rest: addr }
      end

      private_class_method :normalize_town_name, :normalize_addr, :normalize_addr_part
    end
    public_constant :Normalize
  end
end
