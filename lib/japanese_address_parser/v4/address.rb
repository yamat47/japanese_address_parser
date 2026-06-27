# frozen_string_literal: true

# Public value object returned by the v4 API (M6).
# Ruby-original enrichment layer over the faithful NormalizeResult (working_agreement §1-3 / rearchitecture §5.2)。
# JS の NormalizeResult（文字列 pref/city/town）をネストしたリッチ VO に組み替える。

require 'japanese_address_parser/v4/prefecture'
require 'japanese_address_parser/v4/city'
require 'japanese_address_parser/v4/town'

module JapaneseAddressParser
  module V4
    # 正規化結果の公開 VO。prefecture/city/town は未判別なら nil（JS 同様、未マッチは失敗ではない）。
    # metadata は VO に昇格しない生データ（rsdt/chiban 等）の逃がし道（working_agreement §1-3）。
    Address =
      ::Data.define(:full_address, :prefecture, :city, :town, :addr, :other, :point, :level, :metadata) do
        # 内部 NormalizeResult（M5）から公開 Address を組み立てる。
        def self.from_normalize_result(result)
          metadata = result.metadata
          new(
            full_address: metadata.input,
            prefecture: Prefecture.from_metadata(metadata.prefecture),
            city: City.from_metadata(metadata.city),
            town: Town.from_metadata(metadata.machi_aza),
            addr: result.addr,
            other: result.other,
            point: result.point,
            level: result.level,
            metadata: metadata
          )
        end

        # ネストした VO・座標も含めて Hash 化する Ruby 独自 API。metadata は生データの逃がし道として
        # shallow に Hash 化する（内部の SingleCity 等は VO のまま）。
        def to_h
          {
            full_address: full_address,
            prefecture: prefecture&.to_h,
            city: city&.to_h,
            town: town&.to_h,
            addr: addr,
            other: other,
            point: point&.to_h,
            level: level,
            metadata: metadata.to_h
          }
        end
      end
    public_constant :Address
  end
end
