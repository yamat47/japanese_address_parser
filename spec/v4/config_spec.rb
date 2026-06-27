# frozen_string_literal: true

require 'japanese_address_parser/v4/config'

::RSpec.describe(::JapaneseAddressParser::V4::Config) do
  # グローバルなシングルトンを汚さないよう、各例の後でメモ化をリセットする。
  after { ::JapaneseAddressParser::V4.instance_variable_set(:@config, nil) }

  describe 'defaults' do
    subject(:config) { described_class.new }

    it 'defaults japanese_addresses_api to the geolonia endpoint' do
      expect(config.japanese_addresses_api).to(eq('https://japanese-addresses-v2.geoloniamaps.com/api/ja'))
      expect(config.japanese_addresses_api).to(eq(described_class::DEFAULT_ENDPOINT))
    end

    it 'defaults cache_size to 1000' do
      expect(config.cache_size).to(eq(1000))
    end

    it 'defaults geolonia_api_key to nil' do
      expect(config.geolonia_api_key).to(be_nil)
    end
  end

  describe '.config (singleton)' do
    it 'returns the same instance on repeated calls' do
      first = ::JapaneseAddressParser::V4.config
      expect(::JapaneseAddressParser::V4.config).to(be(first))
    end

    it 'is a Config' do
      expect(::JapaneseAddressParser::V4.config).to(be_a(described_class))
    end
  end

  describe '.configure' do
    it 'yields the singleton config so it can be overridden' do
      ::JapaneseAddressParser::V4.configure do |c|
        c.japanese_addresses_api = 'file:///tmp/api/ja'
        c.cache_size = 50
        c.geolonia_api_key = 'secret'
      end

      expect(::JapaneseAddressParser::V4.config.japanese_addresses_api).to(eq('file:///tmp/api/ja'))
      expect(::JapaneseAddressParser::V4.config.cache_size).to(eq(50))
      expect(::JapaneseAddressParser::V4.config.geolonia_api_key).to(eq('secret'))
    end

    it 'returns the config' do
      expect(::JapaneseAddressParser::V4.configure).to(be(::JapaneseAddressParser::V4.config))
    end
  end
end
