# frozen_string_literal: true

require_relative 'address_normalizer/normalize_japanese_addresses_schmoozer'

module JapaneseAddressParser
  module AddressNormalizer
    def call(full_address)
      # https://github.com/geolonia/normalize-japanese-addresses を使って住所を正規化する。
      ::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer.call(full_address)
    end

    module_function :call
  end
end
