# frozen_string_literal: true

require_relative 'japanese_address_parser/address_parser'
require_relative 'japanese_address_parser/version'
require_relative 'japanese_address_parser/normalize_japanese_addresses_schmoozer'

module JapaneseAddressParser
  JS_PACKAGE_PATH = File.expand_path('../js', __dir__)

  module_function

  def call(full_address)
    # https://github.com/geolonia/normalize-japanese-addresses を使って住所を正規化する。
    normalize_japanese_addresses = ::JapaneseAddressParser::NormalizeJapaneseAddressesSchmoozer.new(JS_PACKAGE_PATH)
    result = normalize_japanese_addresses.normalize(full_address)

    ::JapaneseAddressParser::AddressParser.call("#{result['pref']}#{result['city']}#{result['town']}#{result['addr']}")
  end
end
