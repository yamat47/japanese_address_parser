# frozen_string_literal: true

require 'number_to_kanji'
require_relative './prefecture'

module JapaneseAddressParser
  module Models
    class Address
      attr_reader :full_address, :prefecture, :city, :town

      def initialize(full_address)
        @full_address = full_address

        @prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |prefecture| full_address.start_with?(prefecture.name) }

        city_and_after = full_address.delete_prefix(@prefecture.name)
        @city = @prefecture.cities.find { |city| city_and_after.start_with?(city.name) }

        town_and_after = city_and_after.delete_prefix(@city.name)
        hankaku_town_and_after = town_and_after.tr('０-９', '0-9')
        @town =
          @city.towns.find do |town|
            town_and_after_candidates(hankaku_town_and_after).any? do |name|
              name.start_with?(town.name)
            end
          end
      end

      def furigana
        "#{prefecture.name_kana}#{city.name_kana}#{town.name_kana}"
      end

      private

      def town_and_after_candidates(town_and_after)
        @town_and_after_candidates ||= [
          town_and_after,
          town_and_after_number_to_kanji(town_and_after),
          town_and_chome(town_and_after)
        ]
      end

      def town_and_after_number_to_kanji(town_and_after)
        town_and_after.gsub(/(\D*)(\d*)\D.*/) do
          "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
        end
      end

      def town_and_chome(town_and_after)
        town_and_after.gsub(/(\D*)(\d*)-.*$/) do
          "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
        end
      end
    end
  end
end
