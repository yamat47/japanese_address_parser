# frozen_string_literal: true

# Public entry point.
# Ruby-original surface over the faithful Normalize core (working_agreement §1-7 / rearchitecture §5.1, §5.3):
#   - 常に Address を返す（未マッチは level 0 の Address。未マッチは失敗ではない）。
#   - fetch（remote/file）失敗時のみ、call は nil・call! は NormalizeError を raise する。

require 'net/http'
require 'json'
require 'japanese_address_parser/version'
require 'japanese_address_parser/upstream'
require 'japanese_address_parser/exceptions'
require 'japanese_address_parser/normalize'
require 'japanese_address_parser/address'

module JapaneseAddressParser
  # JS: defaultOption = { level: 8 }
  DEFAULT_LEVEL = 8
  public_constant :DEFAULT_LEVEL

  module_function

  # 住所文字列を正規化して Address を返す。fetch 失敗時は nil。
  def call(address, level: DEFAULT_LEVEL)
    call!(address, level:)
  rescue ::JapaneseAddressParser::NormalizeError
    nil
  end

  # 住所文字列を正規化して Address を返す。fetch 失敗時は NormalizeError を raise。
  #
  # rescue で握るのは唯一の I/O 境界 Fetcher が投げ得る「fetch 失敗」のみ（working_agreement §1-7）:
  #   SocketError       — DNS 解決不可・接続不可
  #   SystemCallError   — Errno::*（接続拒否、file:// のファイル無し/権限不足 等）
  #   Net::OpenTimeout / Net::ReadTimeout — タイムアウト
  #   JSON::ParserError — 取得したボディが不正な JSON（配信データの取得失敗）。
  # 設定/プログラマエラー（ArgumentError=未知 URL スキーム 等）は意図的に握らず伝播させる。
  def call!(address, level: DEFAULT_LEVEL)
    Address.from_normalize_result(Normalize.call(address, level:))
  rescue ::SocketError, ::SystemCallError, ::Net::OpenTimeout, ::Net::ReadTimeout, ::JSON::ParserError => e
    raise(::JapaneseAddressParser::NormalizeError, "failed to fetch address data: #{e.message}")
  end
end
