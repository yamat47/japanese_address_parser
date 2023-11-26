# frozen_string_literal: true

require_relative 'japanese_address_parser/address_normalizer'
require_relative 'japanese_address_parser/address_parser'
require_relative 'japanese_address_parser/version'

module JapaneseAddressParser
  def call(full_address)
    _call(full_address)
  rescue ::JapaneseAddressParser::NormalizeError
    nil
  end

  def call!(full_address)
    _call(full_address)
  end

  def _call(full_address)
    normalized = ::JapaneseAddressParser::AddressNormalizer.call(full_address)

    # このライブラリで探索するのは町域まで。
    # それ以降のデータを使って探索するとデータと名前が一致しないことがあるので、町域までのデータを使う。
    ::JapaneseAddressParser::AddressParser.call(normalized: "#{normalized['pref']}#{normalized['city']}#{normalized['town']}", full_address: full_address)
  end

  module_function :call, :call!, :_call
  private_class_method :_call
end
