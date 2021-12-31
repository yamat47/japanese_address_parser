# frozen_string_literal: true

module JapaneseAddressParser
  class Town
    attr_reader :name, :name_kana, :name_romaji, :nickname, :latitude, :longitude

    def initialize(name:, name_kana:, name_romaji:, nickname:, latitude:, longitude:)
      @name = name
      @name_kana = name_kana
      @name_romaji = name_romaji
      @nickname = nickname
      @latitude = latitude
      @longitude = longitude
    end
  end
end
