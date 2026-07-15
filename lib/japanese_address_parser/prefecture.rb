# frozen_string_literal: true

# Rich value object exposed by the v4 public API (M6).
# Ruby-original enrichment layer over the faithful NormalizeResult (working_agreement §1-3).
# 供給元: NormalizeResult#metadata.prefecture（Omit<SinglePrefecture, 'cities'> 相当の Hash）。

require 'japanese_address_parser/normalize_result_point'

module JapaneseAddressParser
  # 都道府県のリッチ VO。point は代表点（NormalizeResultPoint, level 1）。
  Prefecture =
    ::Data.define(:name, :code, :name_kana, :name_romaji, :point) do
      # metadata.prefecture（cities を除いた Hash・Symbol キー）から VO を作る。pref 未判別なら nil。
      # point（level 1 代表点）は都道府県データに必ず存在する（from_lng_lat は nil 受けも安全）。
      def self.from_metadata(hash)
        return if hash.nil?

        new(name: hash[:pref], code: hash[:code], name_kana: hash[:pref_k], name_romaji: hash[:pref_r], point: NormalizeResultPoint.from_lng_lat(hash[:point], level: 1))
      end

      # 緯度経度をネストも含めて Hash 化する Ruby 独自 API。
      def to_h
        { name:, code:, name_kana:, name_romaji:, point: point.to_h }
      end
    end
  public_constant :Prefecture
end
