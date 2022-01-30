# frozen_string_literal: true

require 'schmooze'

module JapaneseAddressParser
  class NormalizeJapaneseAddressesSchmoozer < ::Schmooze::Base
    dependencies normalize_japanese_addresses: '@geolonia/normalize-japanese-addresses'
    method :normalize, 'normalize_japanese_addresses.normalize'
  end
end
