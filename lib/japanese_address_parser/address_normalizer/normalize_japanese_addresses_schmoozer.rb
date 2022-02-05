# frozen_string_literal: true

require 'schmooze'

module JapaneseAddressParser
  module AddressNormalizer
    class NormalizeJapaneseAddressesSchmoozer < ::Schmooze::Base
      JS_PACKAGE_PATH = ::File.expand_path('../../../js', __dir__)
      public_constant :JS_PACKAGE_PATH

      dependencies normalize_japanese_addresses: '@geolonia/normalize-japanese-addresses'
      method :normalize, 'normalize_japanese_addresses.normalize'

      def self.call(full_address)
        new(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer::JS_PACKAGE_PATH).normalize(full_address)
      end
    end
  end
end
