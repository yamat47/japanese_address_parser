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

    def call
      filename = 'lib/japanese_address_parser/data/japanese-addresses.csv'
      header_converters = proc { |h| ::JapaneseAddressParser::CsvParser::HEADER_MAP[h] }
      data = ::CSV.table(filename, header_converters: header_converters, converters: nil)

      prefectures = {}

      data.each do |row|
        current_prefecture = _find_or_build_prefecture(prefectures.keys, row)
        prefectures[current_prefecture] ||= {}

        current_city = _find_or_build_city(prefectures[current_prefecture].keys, current_prefecture, row)
        prefectures[current_prefecture][current_city] ||= []

        stored_town = _find_town(prefectures[current_prefecture][current_city], row)
        stored_town.nil? && (prefectures[current_prefecture][current_city] << _build_town(row))
      end

      _write_csv(prefectures)
    end

    def _find_or_build_prefecture(prefectures, row)
      stored_prefecture = prefectures.find { |prefecture| prefecture.code == row[:prefecture_code] }
      stored_prefecture || ::JapaneseAddressParser::Models::Prefecture.new(
        code: row[:prefecture_code],
        name: row[:prefecture_name],
        name_kana: row[:prefecture_name_kana],
        name_romaji: row[:prefecture_romaji]
      )
    end

    def _find_or_build_city(cities, current_prefecture, row)
      stored_city = cities.find { |city| city.formatted_code == row[:city_code] }
      stored_city || ::JapaneseAddressParser::Models::City.new(
        code: row[:city_code],
        prefecture_code: current_prefecture.code,
        name: row[:city_name],
        name_kana: row[:city_name_kana],
        name_romaji: row[:city_romaji]
      )
    end

    def _find_town(towns, row)
      towns.find { |town| town.name == row[:town_name] }
    end

    def _build_town(row)
      ::JapaneseAddressParser::Models::Town.new(
        name: row[:town_name],
        name_kana: row[:town_name_kana],
        name_romaji: row[:town_name_romaji],
        nickname: row[:town_nickname],
        latitude: row[:latitude],
        longitude: row[:longitude]
      )
    end

    def _write_csv(prefectures)
      _write_prefectures_csv(prefectures.keys)

      prefectures.each do |prefecture, cities|
        _write_cities_csv(prefecture, cities.keys)

        cities.each do |city, towns|
          _write_towns_csv(prefecture, city, towns)
        end
      end
    end

    def _write_prefectures_csv(prefectures)
      filename = 'lib/japanese_address_parser/data/prefectures.csv'
      ::CSV.open(filename, 'w') do |csv|
        csv << %w[code name name_kana name_romaji]
        prefectures.each do |prefecture|
          csv << [prefecture.code, prefecture.name, prefecture.name_kana, prefecture.name_romaji]
        end
      end
    end

    def _write_cities_csv(prefecture, cities)
      filename = "lib/japanese_address_parser/data/#{prefecture.code}.csv"
      ::CSV.open(filename, 'w') do |csv|
        csv << %w[code prefecture_code name name_kana name_romaji]
        cities.each do |city|
          csv << [city.formatted_code, prefecture.code, city.name, city.name_kana, city.name_romaji]
        end
      end
    end

    def _write_towns_csv(prefecture, city, towns)
      filename = "lib/japanese_address_parser/data/#{prefecture.code}-#{city.formatted_code}.csv"
      ::CSV.open(filename, 'w') do |csv|
        csv << %w[name name_kana name_romaji nickname latitude longitude]
        towns.each do |town|
          csv << [town.name, town.name_kana, town.name_romaji, town.nickname, town.latitude, town.longitude]
        end
      end
    end

    module_function :call,
                    :_find_or_build_prefecture,
                    :_find_or_build_city,
                    :_find_town,
                    :_build_town,
                    :_write_csv,
                    :_write_prefectures_csv,
                    :_write_cities_csv,
                    :_write_towns_csv
    private_class_method :_find_or_build_prefecture,
                         :_find_or_build_city,
                         :_find_town,
                         :_build_town,
                         :_write_csv,
                         :_write_prefectures_csv,
                         :_write_cities_csv,
                         :_write_towns_csv
  end
end
