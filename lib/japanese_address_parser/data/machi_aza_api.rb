# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

require 'japanese_address_parser/data/api_meta'
require 'japanese_address_parser/data/single_machi_aza'

module JapaneseAddressParser
  module Data
    # api/ja/{県}/{市}.json のレスポンス全体（町字一覧）。JS の MachiAzaApi。
    MachiAzaApi =
      ::Data.define(:meta, :data) do
        # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
        def self.from_json(hash)
          new(meta: ApiMeta.from_json(hash['meta']), data: (hash['data'] || []).map { |machi_aza| SingleMachiAza.from_json(machi_aza) })
        end
      end
    public_constant :MachiAzaApi
  end
end
