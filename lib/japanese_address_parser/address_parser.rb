# frozen_string_literal: true

require 'number_to_kanji'
require_relative './address_parser/pattern_creator'
require_relative './address_parser/town_and_after_normalizer'
require_relative './models/address'
require_relative './models/prefecture'

module JapaneseAddressParser
  module AddressParser
    def call(full_address)
      prefecture = ::JapaneseAddressParser::Models::Prefecture.all.find { |candidate| full_address.start_with?(candidate.name) }

      return _build_address(full_address: full_address) if prefecture.nil?

      city_and_after = full_address.delete_prefix(prefecture.name)
      city = prefecture.cities.find { |candidate| city_and_after.start_with?(candidate.name) }

      return _build_address(full_address: full_address, prefecture: prefecture) if city.nil?

      town_and_after = city_and_after.delete_prefix(city.name)
      normalized_town_and_after = ::JapaneseAddressParser::AddressParser::TownAndAfterNormalizer.call(town_and_after)
      town_and_after_pattern = ::JapaneseAddressParser::AddressParser::PatternCreator.call(normalized_town_and_after)

      # 多くの場合は正規表現によって一致する町を見つけられる。
      # しかし慣例に従った表記にしている場合は見つからない可能性があるので、前方一致も試してみる。
      town = city.towns.find { |candidate| town_and_after_pattern.match?(candidate.name) }
      town ||= city.towns.find { |candidate| normalized_town_and_after.start_with?(candidate.name) }

      _build_address(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end

    def _build_address(full_address:, prefecture: nil, city: nil, town: nil)
      ::JapaneseAddressParser::Models::Address.new(full_address: full_address, prefecture: prefecture, city: city, town: town)
    end

    module_function :call, :_build_address
    private_class_method :_build_address
  end
end
