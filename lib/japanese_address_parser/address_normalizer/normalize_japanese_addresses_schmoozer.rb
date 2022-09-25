# frozen_string_literal: true

require 'schmooze'

module JapaneseAddressParser
  module AddressNormalizer
    class NormalizeJapaneseAddressesSchmoozer < ::Schmooze::Base
      current_dir = __dir__ || ''

      JS_PACKAGE_PATH = ::File.expand_path('../../../js', current_dir)
      public_constant :JS_PACKAGE_PATH

      JAPANESE_API_PATH = "file://#{::File.expand_path('../data/geolonia-japanese-addresses/api/ja', current_dir)}"
      public_constant :JAPANESE_API_PATH

      dependencies normalize_japanese_addresses: '@geolonia/normalize-japanese-addresses'
      method :set_japanese_api_path, 'function (path) { normalize_japanese_addresses.config.japaneseAddressesApi = path }'
      method :normalize, 'normalize_japanese_addresses.normalize'

      def self.call(full_address)
        schmoozer = new(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer::JS_PACKAGE_PATH)

        # 町丁目データを取得するAPIとしてローカルにあるファイルを指定する。
        # Web APIを利用しないようにすることで処理の効率を向上する。
        # 参考: https://github.com/geolonia/normalize-japanese-addresses#configjapaneseaddressesapi-string
        schmoozer.set_japanese_api_path(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer::JAPANESE_API_PATH)

        schmoozer.normalize(full_address)
      end
    end
  end
end
