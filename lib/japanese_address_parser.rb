# frozen_string_literal: true

require_relative "japanese_address_parser/address"
require_relative "japanese_address_parser/version"

module JapaneseAddressParser
  module_function

  def call(full_address)
    Address.new(full_address)
  end
end
