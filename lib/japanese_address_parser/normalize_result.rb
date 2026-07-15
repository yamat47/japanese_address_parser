# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/types.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3
#   NormalizeResult / NormalizeResultMetadata。M5 では内部表現として使い、公開 VO 化は M6。

require 'japanese_address_parser/normalize_result_point'

module JapaneseAddressParser
  # JS: NormalizeResultMetadata。VO に昇格しない生データの逃がし道（working_agreement §1-3）。
  # prefecture は cities を除いた Hash、machi_aza は csv_ranges を除いた Hash（M2 utils）。
  # chiban / rsdt は M8 で埋まる（level 0-3 では nil）。
  NormalizeResultMetadata = ::Data.define(:input, :prefecture, :city, :machi_aza, :chiban, :rsdt)
  public_constant :NormalizeResultMetadata

  # JS: NormalizeResult。addr は M8（level 8）で埋まる（level 0-3 では nil）。
  NormalizeResult = ::Data.define(:pref, :city, :town, :addr, :other, :point, :level, :metadata)
  public_constant :NormalizeResult
end
