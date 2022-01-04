# frozen_string_literal: true

require 'csv'
require_relative './town'

module JapaneseAddressParser
  module Models
    class City
      attr_reader :code, :prefecture_code, :name, :name_kana, :name_romaji

      def initialize(code:, prefecture_code:, name:, name_kana:, name_romaji:)
        @code = code
        @prefecture_code = prefecture_code
        @name = name
        @name_kana = name_kana
        @name_romaji = name_romaji
      end

      def formatted_code
        code.nil? ? 'UNKNOWN' : code
      end

      def attributes
        { code: code, formatted_code: formatted_code, prefecture_code: prefecture_code, name: name, name_kana: name_kana, name_romaji: name_romaji }
      end

      def prefecture
        ::JapaneseAddressParser::Models::Prefecture.all.find { |prefecture| prefecture.code == prefecture_code }
      end

      def towns
        ::CSV.table("lib/japanese_address_parser/data/#{prefecture_code}-#{formatted_code}.csv", converters: nil).map do |town|
          ::JapaneseAddressParser::Models::Town.new(
            name: town[:name],
            name_kana: town[:name_kana],
            name_romaji: town[:name_romaji],
            nickname: town[:nickname],
            latitude: town[:latitude],
            longitude: town[:longitude]
          )
        end
      end
    end
  end
end
