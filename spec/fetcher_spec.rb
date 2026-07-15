# frozen_string_literal: true

require 'japanese_address_parser/fetcher'
require 'webmock'

::RSpec.describe(::JapaneseAddressParser::Fetcher) do
  include ::WebMock::API

  let(:fixtures_dir) { ::Pathname.new(__dir__).join('fixtures/fetcher').to_s }

  # グローバルな config シングルトンを汚さないよう、各例の後でリセットする。
  after { ::JapaneseAddressParser.instance_variable_set(:@config, nil) }

  describe 'file access (local path)' do
    before { ::JapaneseAddressParser.configure { |c| c.japanese_addresses_api = fixtures_dir } }

    it 'reads the whole file and parses JSON' do
      response = described_class.fetch('/sample.json')

      expect(response.ok).to(be(true))
      expect(response.json).to(eq({ 'pref' => '東京都', 'city' => '渋谷区' }))
    end

    it 'returns the raw text via #text' do
      expect(described_class.fetch('/sample.json').text).to(eq('{"pref":"東京都","city":"渋谷区"}'))
    end

    it 'strips a ?query before reading the local file' do
      expect(described_class.fetch('/sample.json?v=20240101').json).to(eq({ 'pref' => '東京都', 'city' => '渋谷区' }))
    end

    it 'reads only the requested byte range when offset and length are given' do
      # range.txt = "0123456789abcdefghij"; bytes 5..8 => "5678"
      response = described_class.fetch('/range.txt', offset: 5, length: 4)

      expect(response.ok).to(be(true))
      expect(response.text).to(eq('5678'))
    end

    it 'marks ok=false when fewer bytes than requested are available' do
      # offset 18 leaves only 2 bytes ("ij") but 5 were requested
      response = described_class.fetch('/range.txt', offset: 18, length: 5)

      expect(response.ok).to(be(false))
      expect(response.text).to(eq('ij'))
    end
  end

  describe 'file:// scheme' do
    before { ::JapaneseAddressParser.configure { |c| c.japanese_addresses_api = "file://#{fixtures_dir}" } }

    it 'reads the file behind a file:// URL' do
      expect(described_class.fetch('/sample.json').json).to(eq({ 'pref' => '東京都', 'city' => '渋谷区' }))
    end

    # JS は URL#pathname を使うため ?v={apiVersion} 等のクエリはファイルパスに含まれない。
    it 'strips a ?query (e.g. ?v=apiVersion) before reading the file' do
      expect(described_class.fetch('/sample.json?v=20240101').json).to(eq({ 'pref' => '東京都', 'city' => '渋谷区' }))
    end
  end

  describe 'unknown URL scheme' do
    before { ::JapaneseAddressParser.configure { |c| c.japanese_addresses_api = 'ftp://example.com/api' } }

    it 'raises for a scheme that is neither http(s) nor file' do
      expect { described_class.fetch('/x.json') }
        .to(raise_error('Unknown URL schema: ftp:'))
    end
  end

  describe 'http access' do
    let(:base) { 'https://japanese-addresses-v2.geoloniamaps.com/api/ja' }

    around do |example|
      ::WebMock.enable!
      ::WebMock.disable_net_connect!
      example.run
    ensure
      ::WebMock.reset!
      ::WebMock.allow_net_connect!
      ::WebMock.disable!
    end

    it 'builds a percent-encoded URL for a non-ASCII path and parses JSON' do
      stub_request(:get, "#{base}/%E6%9D%B1%E4%BA%AC%E9%83%BD/%E6%B8%8B%E8%B0%B7%E5%8C%BA.json").to_return(status: 200, body: '{"pref":"東京都"}')

      response = described_class.fetch('/東京都/渋谷区.json')

      expect(response.ok).to(be(true))
      expect(response.json).to(eq({ 'pref' => '東京都' }))
    end

    it 'sends the gem User-Agent header' do
      stub_request(:get, "#{base}/a.json").to_return(status: 200, body: '{}')

      response = described_class.fetch('/a.json')

      assert_requested(:get, "#{base}/a.json", headers: { 'User-Agent' => described_class::USER_AGENT })
      expect(response.ok).to(be(true))
    end

    it 'sends a Range header only when offset and length are given' do
      stub_request(:get, "#{base}/b.txt").to_return(status: 206, body: 'partial')

      response = described_class.fetch('/b.txt', offset: 10, length: 20)

      assert_requested(:get, "#{base}/b.txt", headers: { 'Range' => 'bytes=10-29' })
      expect(response.ok).to(be(true))
      expect(response.text).to(eq('partial'))
    end

    it 'does not send a Range header without offset/length' do
      stub_request(:get, "#{base}/c.json").to_return(status: 200, body: '{}')

      response = described_class.fetch('/c.json')

      assert_requested(:get, "#{base}/c.json") { |req| !req.headers.key?('Range') }
      expect(response.ok).to(be(true))
    end

    it 'appends the geolonia-api-key query when configured' do
      ::JapaneseAddressParser.configure { |c| c.geolonia_api_key = 'secret-key' }
      stub_request(:get, "#{base}/d.json").with(query: { 'geolonia-api-key' => 'secret-key' }).to_return(status: 200, body: '{}')

      response = described_class.fetch('/d.json')

      assert_requested(:get, "#{base}/d.json", query: { 'geolonia-api-key' => 'secret-key' })
      expect(response.ok).to(be(true))
    end

    it 'marks ok=false for a non-success status' do
      stub_request(:get, "#{base}/missing.json").to_return(status: 404, body: '')

      expect(described_class.fetch('/missing.json').ok).to(be(false))
    end
  end
end
