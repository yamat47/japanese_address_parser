# frozen_string_literal: true

require_relative '../../../models/prefecture'
require_relative '../../../models/city'
require_relative '../inspired/dict'

module JapaneseAddressParser
  module Normalizers
    module Core
      module Extensions
        # 市区町村マッチング処理
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/cacheRegexes.ts の getCityRegexPatterns を参考に実装
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L80-L101
        class CityMatcher
          # キャッシュ
          @city_patterns_cache = {}

          class << self
            # 市区町村の正規表現パターンを取得
            #
            # @geolonia/normalize-japanese-addresses v2.10.0
            # src/lib/cacheRegexes.ts#L80-L101
            def get_city_regex_patterns(prefecture, cities)
              cache_key = prefecture.code
              cached_result = @city_patterns_cache[cache_key]
              return cached_result if cached_result

              # 少ない文字数の地名に対してミスマッチしないように文字の長さ順にソート
              sorted_cities = cities.sort_by { |city| -city.name.length }

              patterns = sorted_cities.map do |city|
                # toRegexPatternで表記ゆらぎを吸収
                pattern_str = Core::Inspired::Dict.to_regex_pattern(city.name)

                # 町村の場合は郡が省略されている可能性がある
                if city.name.match?(/(町|村)$/)
                  # 郡名を含む場合、郡をオプショナルにする
                  # 例: "上北郡東北町" -> "^(上北郡)?東北町"
                  pattern_str = pattern_str.gsub(/(.+?)郡/, '(\1郡)?')
                end

                pattern = /^#{pattern_str}/
                [city, pattern]
              end

              @city_patterns_cache[cache_key] = patterns
              patterns
            end

            # 住所文字列から市区町村を抽出
            #
            # @param prefecture [Models::Prefecture] 都道府県
            # @param text [String] 住所文字列（都道府県名を除いた部分）
            # @return [Hash] 抽出結果
            def process(prefecture, text)
              return empty_result(text) unless prefecture

              cities = prefecture.cities
              city_patterns = get_city_regex_patterns(prefecture, cities)

              # パターンマッチング
              trimmed_text = text.strip
              city_patterns.each do |city, pattern|
                match = trimmed_text.match(pattern)
                if match
                  return {
                    text: trimmed_text,
                    city: city.name,
                    city_code: city.code,
                    remaining: trimmed_text[match[0].length..-1] || '',
                    matched: true
                  }
                end
              end

              empty_result(trimmed_text)
            end

            private

            def empty_result(text)
              {
                text: text,
                city: '',
                city_code: '',
                remaining: text,
                matched: false
              }
            end
          end

          # パイプライン互換インターフェース（単独では使用不可）
          def self.normalize(text)
            # このメソッドは単独では使用できない
            # PrefectureMatcherと組み合わせて使用する必要がある
            text
          end
        end
      end
    end
  end
end
