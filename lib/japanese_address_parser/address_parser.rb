# frozen_string_literal: true

require 'number_to_kanji'
require_relative './models/address'
require_relative './models/prefecture'

module JapaneseAddressParser
  module AddressParser
    def call(full_address)
      prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |candidate| full_address.start_with?(candidate.name) }

      city_and_after = full_address.delete_prefix(prefecture.name)
      city = prefecture.cities.find { |candidate| city_and_after.start_with?(candidate.name) }

      town_and_after = city_and_after.delete_prefix(city.name)
      town_and_after_candidates = _town_and_after_candidates(town_and_after)
      town =
        city.towns.find do |candidate|
          town_and_after_candidates.any? do |name|
            name.start_with?(candidate.name)
          end
        end

      ::JapaneseAddressParser::Models::Address.new(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end

    def _town_and_after_candidates(town_and_after)
      normalized_town_and_after = _normalize_town_and_after(town_and_after)

      [
        normalized_town_and_after,
        _town_and_after_number_to_kanji(normalized_town_and_after),
        _town_and_chome(normalized_town_and_after)
      ]
    end

    def _normalize_town_and_after(town_and_after)
      town_and_after.tr('０-９', '0-9')
    end

    def _town_and_after_number_to_kanji(town_and_after)
      town_and_after.gsub(/(\D*)(\d*)\D.*/) do
        "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
      end
    end

    def _town_and_chome(town_and_after)
      town_and_after.gsub(/(\D*)(\d*)-.*$/) do
        "#{::Regexp.last_match(1)}#{::NumberToKanji.call(Integer(::Regexp.last_match(2), 10))}丁目"
      end
    end

    module_function :call,
                    :_town_and_after_candidates,
                    :_town_and_after_number_to_kanji,
                    :_town_and_chome,
                    :_normalize_town_and_after
    private_class_method :_town_and_after_candidates, :_town_and_after_number_to_kanji, :_town_and_chome, :_normalize_town_and_after
  end
end
