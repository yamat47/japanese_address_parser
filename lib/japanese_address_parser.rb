# frozen_string_literal: true

require_relative 'japanese_address_parser/address_normalizer'
require_relative 'japanese_address_parser/address_parser'
require_relative 'japanese_address_parser/version'

module JapaneseAddressParser
  module_function

  def call(full_address)
    normalized = ::JapaneseAddressParser::AddressNormalizer.call(full_address)

    # このライブラリで探索するのは町域まで。
    # それ以降のデータを使って探索するとデータと名前が一致しないことがあるので、町域までのデータを使う。
    ::JapaneseAddressParser::AddressParser.call("#{normalized['pref']}#{normalized['city']}#{normalized['town']}")
  end
end
