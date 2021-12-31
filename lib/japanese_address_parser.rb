# frozen_string_literal: true

require_relative "japanese_address_parser/version"
require_relative "japanese_address_parser/models/address"

module JapaneseAddressParser
  module_function

  def call(full_address)
    Models::Address.new(full_address)
  end
end
