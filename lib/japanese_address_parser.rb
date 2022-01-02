# frozen_string_literal: true

require_relative 'japanese_address_parser/address_parser'
require_relative 'japanese_address_parser/version'

module JapaneseAddressParser
  module_function

  def call(full_address)
    ::JapaneseAddressParser::AddressParser.call(full_address)
  end
end
