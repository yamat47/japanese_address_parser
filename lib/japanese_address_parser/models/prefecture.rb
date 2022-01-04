# frozen_string_literal: true

require 'csv'
require 'pathname'
require_relative './city'

module JapaneseAddressParser
  module Models
    class Prefecture
      attr_reader :code, :name, :name_kana, :name_romaji

      def self.all
        filepath = Pathname(__FILE__).dirname.join('../data/prefectures.csv')
        ::CSV.table(filepath, converters: nil).map do |prefecture|
          new(
            code: prefecture[:code],
            name: prefecture[:name],
            name_kana: prefecture[:name_kana],
            name_romaji: prefecture[:name_romaji]
          )
        end
      end

      def initialize(code:, name:, name_kana:, name_romaji:)
        @code = code
        @name = name
        @name_kana = name_kana
        @name_romaji = name_romaji
      end

      def attributes
        { code: code, name: name, name_kana: name_kana, name_romaji: name_romaji }
      end

      def cities
        filepath = Pathname(__FILE__).dirname.join("../data/#{code}.csv")
        ::CSV.table(filepath, converters: nil).map do |city|
          ::JapaneseAddressParser::Models::City.new(
            code: city[:code],
            prefecture_code: city[:prefecture_code],
            name: city[:name],
            name_kana: city[:name_kana],
            name_romaji: city[:name_romaji]
          )
        end
      end
    end
  end
end
