# frozen_string_literal: true

require 'csv'
require_relative './city'

class Prefecture
  attr_reader :code, :name, :name_kana, :name_romaji

  class << self
    def all
      CSV.table('./parsed_data/prefectures.csv').map do |prefecture|
        new(
          code: prefecture[:code],
          name: prefecture[:name],
          name_kana: prefecture[:name_kana],
          name_romaji: prefecture[:name_romaji]
        )
      end
    end
  end

  def initialize(code:, name:, name_kana:, name_romaji:)
    @code = code
    @name = name
    @name_kana = name_kana
    @name_romaji = name_romaji
  end

  def formatted_code
    format("%02<number>d", number: code)
  end

  def cities
    CSV.table("./parsed_data/#{formatted_code}.csv").map do |city|
      City.new(
        code: city[:code],
        prefecture_code: city[:prefecture_code],
        name: city[:name],
        name_kana: city[:name_kana],
        name_romaji: city[:name_romaji]
      )
    end
  end
end
