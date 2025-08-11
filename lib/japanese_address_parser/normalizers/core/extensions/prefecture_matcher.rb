# frozen_string_literal: true

require_relative '../../../models/prefecture'

module JapaneseAddressParser
  module Normalizers
    module Core
      module Extensions
        # 都道府県マッチング処理
        #
        # @geolonia/normalize-japanese-addresses v2.10.0
        # src/lib/cacheRegexes.ts の getPrefectureRegexPatterns を参考に実装
        # https://github.com/geolonia/normalize-japanese-addresses/blob/v2.10.0/src/lib/cacheRegexes.ts#L66-L78
        class PrefectureMatcher
          # 都道府県のキャッシュ
          @prefecture_cache = nil
          @prefecture_patterns = nil

          class << self
            # 都道府県データを事前ロード
            def preload
              @prefecture_cache ||= ::JapaneseAddressParser::Models::Prefecture.all
              build_patterns unless @prefecture_patterns
              true
            end

            # 住所文字列から都道府県を抽出
            #
            # @param text [String] 住所文字列
            # @return [Hash] 抽出結果
            def process(text)
              preload

              # 都道府県のマッチング
              prefecture = find_prefecture(text)

              if prefecture
                # マッチした部分を削除して残りを取得
                match = text.match(@prefecture_patterns[prefecture])
                remaining = text[match[0].length..-1] || ''

                {
                  text: text,
                  pref: prefecture.name,
                  pref_code: prefecture.code,
                  remaining: remaining,
                  matched: true
                }
              else
                {
                  text: text,
                  pref: '',
                  pref_code: '',
                  remaining: text,
                  matched: false
                }
              end
            end

            private

            # 都道府県の正規表現パターンを構築
            # @geolonia/normalize-japanese-addresses v2.10.0
            # src/lib/cacheRegexes.ts#L71-L74
            def build_patterns
              @prefecture_patterns = {}

              @prefecture_cache.each do |prefecture|
                # 東京都 -> 東京(都)? のようなパターンを作成
                # 末尾の「都府県」が抜けた住所に対応
                pref_name_without_suffix = prefecture.name.gsub(/(都|道|府|県)$/, '')
                pattern = /^#{Regexp.escape(pref_name_without_suffix)}(都|道|府|県)?/
                @prefecture_patterns[prefecture] = pattern
              end
            end

            # 都道府県を検索
            def find_prefecture(text)
              @prefecture_cache.find do |prefecture|
                pattern = @prefecture_patterns[prefecture]
                text.match?(pattern)
              end
            end
          end

          # パイプライン互換インターフェース
          def self.normalize(text)
            result = process(text)
            result[:text]
          end
        end
      end
    end
  end
end
