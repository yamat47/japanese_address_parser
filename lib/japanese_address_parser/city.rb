# frozen_string_literal: true

require 'csv'
require_relative './town'

module JapaneseAddressParser
  class City
    attr_reader :code, :prefecture_code, :name, :name_kana, :name_romaji

    def initialize(code:, prefecture_code:, name:, name_kana:, name_romaji:)
      @code = code
      @prefecture_code = format("%02<number>d", number: prefecture_code)
      @name = name
      @name_kana = name_kana
      @name_romaji = name_romaji
    end

    def formatted_code
      code.nil? ? 'UNKNOWN' : format("%05<number>d", number: code)
    end

    def prefecture
      Prefecture.all.detect { |prefecture| prefecture.formatted_code == prefecture_code }
    end

    def towns
      CSV.table("lib/japanese_address_parser/data/#{prefecture_code}-#{formatted_code}.csv").map do |town|
        Town.new(
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
