# frozen_string_literal: true

require_relative 'address_normalizer/normalize_japanese_addresses_schmoozer'
require_relative 'address_normalizer/pure_ruby_normalizer'
require_relative 'exceptions'

module JapaneseAddressParser
  module AddressNormalizer
    def call(full_address)
      # Pure Ruby実装による住所正規化・解析を使用
      # JavaScriptに依存しない純粋なRuby実装
      ::JapaneseAddressParser::AddressNormalizer::PureRubyNormalizer.call(full_address)
    rescue ::StandardError
      raise(::JapaneseAddressParser::NormalizeError)
    end

    # 下位互換性・比較用のJavaScript実装
    def call_with_javascript(full_address)
      # https://github.com/geolonia/normalize-japanese-addresses を使って住所を正規化する。
      ::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer.call(full_address)

    # Schmoozeが稀に例外を吐くことがある。
    # ライブラリを利用するときに扱いやすくするために例外のクラスを固定しておく。
    rescue ::StandardError
      raise(::JapaneseAddressParser::NormalizeError)
    end

    module_function :call, :call_with_javascript
  end
end
