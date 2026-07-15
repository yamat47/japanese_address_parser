# frozen_string_literal: true

require 'japanese_address_parser/version'
require 'japanese_address_parser/v4'

module JapaneseAddressParser
  # 公開 API は v4 実装へ委譲する（V4 名前空間の物理昇格は後続コミットで行う）。
  def call(address, level: ::JapaneseAddressParser::V4::DEFAULT_LEVEL)
    ::JapaneseAddressParser::V4.call(address, level:)
  end

  def call!(address, level: ::JapaneseAddressParser::V4::DEFAULT_LEVEL)
    ::JapaneseAddressParser::V4.call!(address, level:)
  end

  module_function :call, :call!
end
