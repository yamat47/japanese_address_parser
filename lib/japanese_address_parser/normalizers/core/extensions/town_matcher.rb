# frozen_string_literal: true

require 'set'
require 'ostruct'
require_relative '../../../models/city'
require_relative '../../../models/town'
require_relative '../inspired/dict'
require_relative '../inspired/kan2num'

module JapaneseAddressParser
  module Normalizers
    module Core
      module Extensions
        # 町域マッチング処理
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/normalize.ts の normalizeTownName 関数
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/normalize.ts#L174-L198
        # src/lib/cacheRegexes.ts の getTownRegexPatterns 関数
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L223-L334
        class TownMatcher
          # 町域パターンのキャッシュ（LRU的な実装は省略）
          @town_patterns_cache = {}

          class << self
            # 町域の正規表現パターンを取得
            #
            # @geolonia/normalize-japanese-addresses v2.10.0
            # src/lib/cacheRegexes.ts#L223-L334
            def get_town_regex_patterns(city)
              cache_key = city.code
              cached_result = @town_patterns_cache[cache_key]
              return cached_result if cached_result

              pre_towns = city.towns
              town_set = Set.new(pre_towns.map(&:name))
              towns = []

              is_kyoto = city.name.match?(/^京都市/)

              # 町丁目に「○○町」が含まれるケースへの対応
              # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L235-L258
              pre_towns.each do |town|
                towns << town

                original_town = town.name
                next unless original_town.include?('町')

                # 冒頭の「町」は明らかに省略するべきではないので、除外
                town_abbr = original_town.gsub(/(?!^町)町/, '')

                # 京都は通り名削除の処理があるため、意図しないマッチになるケースがある
                # 同名の町域が存在する場合は省略形を作らない
                # 漢数字＋町の組み合わせ（十六町など）も除外
                next unless !is_kyoto && !town_set.include?(town_abbr) && !town_set.include?("大字#{town_abbr}") && !is_kanji_number_followed_by_cho(original_town)

                # エイリアスとして町なしのパターンを登録
                towns << OpenStruct.new(name: town_abbr, original_town: original_town, name_kana: town.name_kana, latitude: town.latitude, longitude: town.longitude)
              end

              # 少ない文字数の地名に対してミスマッチしないように文字の長さ順にソート
              # 大字で始まる場合、優先度を低く設定
              # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L260-L271
              towns.sort! do |a, b|
                a_len = a.name.length
                b_len = b.name.length

                # 大字で始まる場合、優先度を低く設定
                a_len -= 2 if a.name.start_with?('大字')
                b_len -= 2 if b.name.start_with?('大字')

                b_len - a_len
              end

              # パターン生成
              # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L273-L314
              patterns =
                towns.map do |town|
                               pattern_str = Core::Inspired::Dict.to_regex_pattern(
                                 town.name
                                   # 横棒を含む場合（流通センター、など）に対応
                                   .gsub(/[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]/, '[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━]')
                                   .gsub(/大?字/, '(大?字)?')
                               )

                               # 住所マスターの町丁目に含まれる数字を正規表現に変換
                               pattern_str =
                                 pattern_str.gsub(
                                                  /([壱一二三四五六七八九十]+)(丁目?|番(町|丁)|条|軒|線|(の|ノ)町|地割|号)/
                                                ) do |match|
                                                  patterns = []

                                                  # 漢数字部分を抽出
                                                  kanji_num = match.gsub(/(丁目?|番(町|丁)|条|軒|線|(の|ノ)町|地割|号)/, '')
                                                  patterns << kanji_num

                                                  if match.start_with?('壱')
                                                    patterns << '一'
                                                    patterns << '1'
                                                    patterns << '１'
                                                  else
                                                    # 漢数字をアラビア数字に変換
                                                    num = Core::Inspired::Kan2num.normalize(kanji_num)
                                                    patterns << num.to_s
                                                  end

                                                  "(#{patterns.join('|')})((丁|町)目?|番(町|丁)|条|軒|線|の町?|地割|号|[-－﹣−‐⁃‑‒–—﹘―⎯⏤ーｰ─━])"
                                                end

                               pattern = /#{pattern_str}/
                               [town, pattern]
                end

              # X丁目の丁目なしの数字だけ許容するため、最後に数字だけ追加
              # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L316-L330
              towns.each do |town|
                chome_match = town.name.match(/([^一二三四五六七八九十]+)([一二三四五六七八九十]+)(丁目?)/)
                next unless chome_match

                chome_name_part = chome_match[1]
                chome_num = chome_match[2]
                pattern_str = Core::Inspired::Dict.to_regex_pattern("^#{chome_name_part}(#{chome_num}|#{Core::Inspired::Kan2num.normalize(chome_num)})")
                pattern = /#{pattern_str}/
                patterns << [town, pattern]
              end

              @town_patterns_cache[cache_key] = patterns
              patterns
            end

            # 住所文字列から町域を抽出
            #
            # @geolonia/normalize-japanese-addresses v2.10.0
            # src/normalize.ts#L174-L198
            def process(city, text)
              return empty_result(text) unless city

              # 先頭の「大字」を削除
              addr = text.strip.gsub(/^大字/, '')

              town_patterns = get_town_regex_patterns(city)

              # 京都の場合は前方一致と後方一致の両方を試す
              # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/normalize.ts#L178-L182
              regex_prefixes = ['^']
              regex_prefixes << '.*' if city.name.match?(/^京都市/)

              regex_prefixes.each do |regex_prefix|
                town_patterns.each do |town, pattern_base|
                  # パターンに前方/後方一致を追加
                  pattern = /#{regex_prefix}#{pattern_base.source}/
                  match = addr.match(pattern)

                  next unless match

                  # original_townが設定されている場合はそれを使用
                  town_name = town.respond_to?(:original_town) && town.original_town ? town.original_town : town.name
                  remaining = addr[match[0].length..-1] || ''

                  return {
                    text: text,
                    town: town_name,
                    town_kana: town.name_kana,
                    latitude: town.latitude,
                    longitude: town.longitude,
                    remaining: remaining,
                    matched: true
                  }
                end
              end

              empty_result(text)
            end

            private

            def empty_result(text)
              {
                text: text,
                town: '',
                town_kana: '',
                latitude: nil,
                longitude: nil,
                remaining: text,
                matched: false
              }
            end

            # 十六町 のように漢数字と町が連結しているか
            # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L215-L221
            def is_kanji_number_followed_by_cho(target_town_name)
              x_cho = target_town_name.scan(/.町/)
              return false if x_cho.empty?

              # 漢数字パターン
              x_cho[0].match?(/[一二三四五六七八九十百千万壱弐参]町/)
            end
          end

          # パイプライン互換インターフェース（単独では使用不可）
          def self.normalize(text)
            # このメソッドは単独では使用できない
            # CityMatcherと組み合わせて使用する必要がある
            text
          end
        end
      end
    end
  end
end
