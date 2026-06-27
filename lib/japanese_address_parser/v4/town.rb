# frozen_string_literal: true

# Rich value object exposed by the v4 public API (M6).
# Ruby-original enrichment layer over the faithful NormalizeResult (working_agreement §1-3).
# 供給元: NormalizeResult#metadata.machi_aza（Omit<SingleMachiAza, 'csv_ranges'> 相当の Hash）。

require 'japanese_address_parser/v4/normalize_result_point'

module JapaneseAddressParser
  module V4
    # 町字のリッチ VO。name は machiAzaName（大字＋丁目＋小字）。point は代表点（NormalizeResultPoint, level 3）。
    # chome は "一丁目" 等の文字列、chome_n は 1 等の整数（JS SingleMachiAza が両方持つため両方公開する）。
    Town =
      ::Data.define(:name, :machiaza_id, :chome, :chome_n, :koaza, :point) do
        # metadata.machi_aza（csv_ranges を除いた Hash・Symbol キー）から VO を作る。town 未判別なら nil。
        # point（level 3 代表点）は町字によっては存在しないため from_lng_lat が nil を返す。
        # name は Hash 入力のため SingleMachiAza#machi_aza_name を呼べない。式は同メソッド（JS: machiAzaName）と一致させる。
        def self.from_metadata(hash)
          return if hash.nil?

          new(
            name: "#{hash[:oaza_cho]}#{hash[:chome]}#{hash[:koaza]}",
            machiaza_id: hash[:machiaza_id],
            chome: hash[:chome],
            chome_n: hash[:chome_n],
            koaza: hash[:koaza],
            point: NormalizeResultPoint.from_lng_lat(hash[:point], level: 3)
          )
        end

        # 緯度経度をネストも含めて Hash 化する Ruby 独自 API。
        def to_h
          { name: name, machiaza_id: machiaza_id, chome: chome, chome_n: chome_n, koaza: koaza, point: point&.to_h }
        end
      end
    public_constant :Town
  end
end
