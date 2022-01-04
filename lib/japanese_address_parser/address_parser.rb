# frozen_string_literal: true

require 'number_to_kanji'
require_relative './address_parser/town_and_after_normalizer'
require_relative './models/address'
require_relative './models/prefecture'

module JapaneseAddressParser
  module AddressParser
    def call(full_address)
      prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |candidate| full_address.start_with?(candidate.name) }

      city_and_after = full_address.delete_prefix(prefecture.name)
      city = prefecture.cities.find { |candidate| city_and_after.start_with?(candidate.name) }

      town_and_after = city_and_after.delete_prefix(city.name)
      normalized_town_and_after = ::JapaneseAddressParser::AddressParser::TownAndAfterNormalizer.call(town_and_after)
      town = city.towns.find { |candidate| normalized_town_and_after.start_with?(candidate.name) }

      ::JapaneseAddressParser::Models::Address.new(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end

    module_function :call
  end
end
