# frozen_string_literal: true

require 'csv'
require_relative './models/prefecture'
require_relative './models/city'
require_relative './models/town'

module JapaneseAddressParser
  module CsvParser
    HEADER_MAP = {
      '都道府県コード' => :prefecture_code,
      '都道府県名' => :prefecture_name,
      '都道府県名カナ' => :prefecture_name_kana,
      '都道府県名ローマ字' => :prefecture_romaji,
      '市区町村コード' => :city_code,
      '市区町村名' => :city_name,
      '市区町村名カナ' => :city_name_kana,
      '市区町村名ローマ字' => :city_romaji,
      '大字町丁目名' => :town_name,
      '大字町丁目名カナ' => :town_name_kana,
      '大字町丁目名ローマ字' => :town_name_romaji,
      '小字・通称名' => :town_nickname,
      '緯度' => :latitude,
      '経度' => :longitude
    }.freeze

    public_constant :HEADER_MAP

    module_function

    def call
      data = ::CSV.table(
        'lib/japanese_address_parser/data/japanese-addresses.csv',
        header_converters: proc { |h|
          ::JapaneseAddressParser::CsvParser::HEADER_MAP[h]
        }
      )

      prefectures = {}

      data.each do |row|
        current_prefecture = prefectures.keys.find { |prefecture| prefecture.code == row[:prefecture_code] }

        if current_prefecture.nil?
          current_prefecture = ::JapaneseAddressParser::Models::Prefecture.new(
            code: row[:prefecture_code],
            name: row[:prefecture_name],
            name_kana: row[:prefecture_name_kana],
            name_romaji: row[:prefecture_romaji]
          )

          prefectures[current_prefecture] = {}
        end

        current_city = prefectures[current_prefecture].keys.find { |city| city.code == row[:city_code] }

        if current_city.nil?
          current_city = ::JapaneseAddressParser::Models::City.new(
            code: row[:city_code],
            prefecture_code: current_prefecture.code,
            name: row[:city_name],
            name_kana: row[:city_name_kana],
            name_romaji: row[:city_romaji]
          )

          prefectures[current_prefecture][current_city] = []
        end

        current_town = prefectures[current_prefecture][current_city].find { |town| town.name == row[:town_name] }

        next unless current_town.nil?

        current_town = ::JapaneseAddressParser::Models::Town.new(
          name: row[:town_name],
          name_kana: row[:town_name_kana],
          name_romaji: row[:town_name_romaji],
          nickname: row[:town_nickname],
          latitude: row[:latitude],
          longitude: row[:longitude]
        )

        prefectures[current_prefecture][current_city] << current_town
      end

      ::CSV.open('lib/japanese_address_parser/data/prefectures.csv', 'w') do |csv|
        csv << %w[code name name_kana name_romaji]
        prefectures.each_key do |prefecture|
          csv << [prefecture.formatted_code, prefecture.name, prefecture.name_kana, prefecture.name_romaji]
        end
      end

      prefectures.each do |prefecture, cities|
        ::CSV.open("lib/japanese_address_parser/data/#{prefecture.formatted_code}.csv", 'w') do |csv|
          csv << %w[code prefecture_code name name_kana name_romaji]
          cities.each_key do |city|
            csv << [city.formatted_code, prefecture.formatted_code, city.name, city.name_kana, city.name_romaji]
          end
        end

        cities.each do |city, towns|
          ::CSV.open(
            "lib/japanese_address_parser/data/#{prefecture.formatted_code}-#{city.formatted_code}.csv",
            'w'
          ) do |csv|
            csv << %w[name name_kana name_romaji nickname latitude longitude]
            towns.each do |town|
              csv << [town.name, town.name_kana, town.name_romaji, town.nickname, town.latitude, town.longitude]
            end
          end
        end
      end
    end
  end
end
