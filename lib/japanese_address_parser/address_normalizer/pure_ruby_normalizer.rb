# frozen_string_literal: true

require_relative '../normalizers/pure_ruby'
require_relative '../normalizers/core/extensions/prefecture_matcher'
require_relative '../normalizers/core/extensions/city_matcher'
require_relative '../normalizers/core/extensions/town_matcher'
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

        # Step 2: 都道府県を特定（新しいMatcherを使用）
        pref_result = ::JapaneseAddressParser::Normalizers::Core::Extensions::PrefectureMatcher.process(normalized)
        unless pref_result[:matched]
          return default_result(full_address)
        end

        prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |p| p.name == pref_result[:pref] }
        return default_result(full_address) if prefecture.nil?

        # Step 3: 市区町村を特定（新しいMatcherを使用）
        city_result = ::JapaneseAddressParser::Normalizers::Core::Extensions::CityMatcher.process(
          prefecture, 
          pref_result[:remaining]
        )
        
        unless city_result[:matched]
          return prefecture_result(full_address, prefecture)
        end

        city = prefecture.cities.find { |c| c.name == city_result[:city] }
        return prefecture_result(full_address, prefecture) if city.nil?

        # Step 4: 町丁目を特定（新しいMatcherを使用）
        town_match_result = ::JapaneseAddressParser::Normalizers::Core::Extensions::TownMatcher.process(
          city,
          city_result[:remaining]
        )

        if town_match_result[:matched]
          town = city.towns.find { |t| t.name == town_match_result[:town] }
          return town_result(full_address, prefecture, city, town, town_match_result[:remaining]) if town
        end

        city_result(full_address, prefecture, city, city_result[:remaining])
      end

      private_class_method :new

      private

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

      private_class_method :default_result, :prefecture_result, :city_result, :town_result
    end
  end
end
