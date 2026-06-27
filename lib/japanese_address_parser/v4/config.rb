# frozen_string_literal: true

# Port of: https://github.com/geolonia/normalize-japanese-addresses/blob/49c1ae4be9d2ba353b86eaf40fd7eb12a1269f3e/src/config.ts
# Upstream: @geolonia/normalize-japanese-addresses v3.1.3

module JapaneseAddressParser
  # v4.0.0 リアーキテクチャの名前空間。グローバル設定（config シングルトン / configure ブロック）を提供する。
  module V4
    # JS の config.ts。currentConfig（可変シングルトン）に対応する設定オブジェクト。
    # japanese_addresses_api / cache_size / geolonia_api_key を保持する。
    class Config
      # JS: defaultEndpoint — 末尾スラッシュ無し（fetch 側で `${api}${input}` と連結する）。
      DEFAULT_ENDPOINT = 'https://japanese-addresses-v2.geoloniamaps.com/api/ja'

      public_constant :DEFAULT_ENDPOINT

      # JS: japaneseAddressesApi / cacheSize / geoloniaApiKey
      attr_accessor :japanese_addresses_api, :cache_size, :geolonia_api_key

      # JS: currentConfig = { japaneseAddressesApi: defaultEndpoint, cacheSize: 1_000 }
      def initialize
        @japanese_addresses_api = DEFAULT_ENDPOINT
        @cache_size = 1_000
        @geolonia_api_key = nil
      end
    end
    public_constant :Config

    # JS: currentConfig（モジュールレベルの可変シングルトン）。
    def self.config
      @config ||= Config.new
    end

    # Ruby 慣習の設定ブロック。`V4.configure { |c| c.cache_size = ... }` のように使う。
    def self.configure
      yield(config) if block_given?
      config
    end
  end
end
