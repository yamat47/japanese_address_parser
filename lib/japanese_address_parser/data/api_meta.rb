# frozen_string_literal: true

# Port of: https://github.com/geolonia/japanese-addresses-v2/blob/bb4d000ae136d8b8b571ebccd39a772cc6afc67a/src/data.ts
# Upstream: @geolonia/japanese-addresses-v2 v0.0.5 (data spec for @geolonia/normalize-japanese-addresses v3.1.3)

module JapaneseAddressParser
  module Data
    # API レスポンスの meta。`updated` はデータの更新時刻で、町字/サブリソース取得時の
    # `?v={apiVersion}` に使う（キャッシュバスティング）。
    ApiMeta =
      ::Data.define(:updated) do
        # JSON（パース済み Hash・文字列キー）から VO を生成する Ruby 独自ヘルパ。
        def self.from_json(hash)
          new(updated: hash['updated'])
        end
      end
    public_constant :ApiMeta
  end
end
