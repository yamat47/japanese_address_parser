# frozen_string_literal: true

require_relative '../normalizers/pure_ruby'
require_relative '../models/prefecture'
require_relative '../models/city'
require_relative '../models/town'

module JapaneseAddressParser
  module AddressNormalizer
    # JavaScript実装を置き換えるPure Ruby住所パーサー
    #
    # @geolonia/normalize-japanese-addresses の機能をPure Rubyで再現
    # 同じAPIを提供してJavaScript依存を除去
    class PureRubyNormalizer
      def self.call(full_address)
        return default_result(full_address) if full_address.nil? || full_address.empty?

        # Step 1: 純粋Ruby正規化を適用
        normalized = ::JapaneseAddressParser::Normalizers::PureRuby.full_normalize(full_address)

        # Step 2: 都道府県を特定
        prefecture = find_prefecture(normalized)
        return default_result(full_address) if prefecture.nil?

        # Step 3: 市区町村を特定
        city_and_after = normalized.delete_prefix(prefecture.name)
        city = find_city(prefecture, city_and_after)
        return prefecture_result(full_address, prefecture) if city.nil?

        # Step 4: 町丁目を特定
        town_and_after = city_and_after.delete_prefix(city.name)
        town = find_town(city, town_and_after)

        if town.nil?
          city_result(full_address, prefecture, city, town_and_after)
        else
          town_result(full_address, prefecture, city, town, town_and_after)
        end
      end

      private_class_method :new

      private

      def self.find_prefecture(normalized)
        ::JapaneseAddressParser::Models::Prefecture.all.find { |pref| normalized.start_with?(pref.name) }
      end

      def self.find_city(prefecture, text)
        prefecture.cities.find { |city| text.start_with?(city.name) }
      end

      def self.find_town(city, text)
        # 1. 完全一致を優先
        exact_match = city.towns.find { |town| text == town.name }
        return exact_match if exact_match

        # 2. 前方一致で最長のものを選ぶ
        prefix_matches = city.towns.select { |town| text.start_with?(town.name) }
        longest_prefix = prefix_matches.max_by { |town| town.name.length }
        return longest_prefix if longest_prefix

        # 3. 特殊パターンマッチング: 「地名 + 数字」を「地名 + 漢数字 + 丁目」にマッピング
        # 例: "恵比寿1" -> "恵比寿一丁目"
        if text =~ /^(.+?)(\d+)(.*)$/
          base_name = ::Regexp.last_match[1]
          number = ::Regexp.last_match[2].to_i
          suffix = ::Regexp.last_match[3]

          # 数字を漢数字に変換
          kanji_number = convert_to_kanji_number(number)

          # 「基本名 + 漢数字 + 丁目」の形式で探す
          candidate_name = "#{base_name}#{kanji_number}丁目"
          pattern_match = city.towns.find { |town| town.name == candidate_name }

          return pattern_match if pattern_match
        end

        nil
      end

      def self.convert_to_kanji_number(number)
        case number
        when 1 then '一'
        when 2 then '二'
        when 3 then '三'
        when 4 then '四'
        when 5 then '五'
        when 6 then '六'
        when 7 then '七'
        when 8 then '八'
        when 9 then '九'
        when 10 then '十'
        else number.to_s
        end
      end

      def self.default_result(full_address)
        {
          'pref' => '',
          'city' => '',
          'town' => '',
          'addr' => full_address,
          'level' => 0,
          'lat' => nil,
          'lng' => nil
        }
      end

      def self.prefecture_result(full_address, prefecture)
        {
          'pref' => prefecture.name,
          'city' => '',
          'town' => '',
          'addr' => full_address,
          'level' => 1,
          'lat' => nil,
          'lng' => nil
        }
      end

      def self.city_result(_full_address, prefecture, city, remaining)
        {
          'pref' => prefecture.name,
          'city' => city.name,
          'town' => '',
          'addr' => remaining,
          'level' => 2,
          'lat' => nil,
          'lng' => nil
        }
      end

      def self.town_result(_full_address, prefecture, city, town, remaining)
        # 町域名から残りのアドレス部分を取得
        addr = remaining.delete_prefix(town.name)

        {
          'pref' => prefecture.name,
          'city' => city.name,
          'town' => town.name,
          'addr' => addr,
          'level' => 3,
          'lat' => town.latitude&.to_f,
          'lng' => town.longitude&.to_f
        }
      end

      private_class_method :find_prefecture, :find_city, :find_town, :convert_to_kanji_number, :default_result, :prefecture_result, :city_result, :town_result
    end
  end
end
