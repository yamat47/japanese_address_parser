# frozen_string_literal: true

module JapaneseAddressParser
  module Models
    class Address
      attr_reader :full_address, :prefecture, :city, :town, :addr

      def initialize(full_address:, prefecture:, city:, town:, addr:)
        @full_address = full_address
        @prefecture = prefecture
        @city = city
        @town = town
        @addr = addr
      end

      def furigana
        "#{prefecture&.name_kana}#{city&.name_kana}#{town&.name_kana}"
      end
    end
  end
end
