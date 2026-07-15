# frozen_string_literal: true

# Port of test/main/filesystem-api.test.ts。CDN から tmpdir に落とし file:// で読む経路を検証する。
# RSpec は 1 プロセス共有なので、Config 切替の前後で CacheRegexes.reset! してキャッシュを分離する
# （JS は test ファイルごとに別プロセスでモジュール状態が新鮮になる。それに相当する）。

require 'tmpdir'
require 'fileutils'
require 'japanese_address_parser'
require 'japanese_address_parser/cache_regexes'
require_relative 'support/match_close_to'

::RSpec.describe(::JapaneseAddressParser, :upstream_port) do
  # describe ボディの local をフックがクロージャで共有する（インスタンス変数を避ける）。
  tmpdir = nil

  # live CDN から ja.json と 東京都/渋谷区.json を一度だけ tmpdir に落とす（千代田区.json は
  # 意図的に用意しない＝未提供エリアの検証用）。データは不変なので example ごとに落とし直さない。
  before(:context) do
    tmpdir = ::Dir.mktmpdir('jap-addr-fs-')
    # ja.json / 渋谷区.json（町字）に加え、level 8 の住居表示 .txt も落とす（上流 filesystem-api.test.ts と同じ）。
    ['.json', '/東京都/渋谷区.json', '/東京都/渋谷区-住居表示.txt'].each do |relative|
      # Config base が file://#{tmpdir}/ja なので ja.json と ja/東京都/... が並ぶ。
      path = "#{tmpdir}/ja#{relative}"
      ::FileUtils.mkdir_p(::File.dirname(path))
      ::File.write(path, ::JapaneseAddressParser::Fetcher.fetch(relative).body)
    end
  end

  after(:context) { ::FileUtils.remove_entry(tmpdir) if tmpdir }

  # file:// への切替とキャッシュ分離は example ごとに行う（JS の test ファイル単位プロセス分離に相当）。
  around do |example|
    original_api = described_class.config.japanese_addresses_api
    described_class.config.japanese_addresses_api = "file://#{tmpdir}/ja"
    ::JapaneseAddressParser::CacheRegexes.reset!
    begin
      example.run
    ensure
      described_class.config.japanese_addresses_api = original_api
      ::JapaneseAddressParser::CacheRegexes.reset!
    end
  end

  it 'normalizes through the file:// data source (level 3)' do
    expect(described_class.call('渋谷区道玄坂1-10-8', level: 3)).to(match_close_to(pref: '東京都', city: '渋谷区', town: '道玄坂一丁目', level: 3))
  end

  context 'when the area file is not provided (上流: e.code === ENOENT)' do
    it 'returns nil from call (ENOENT → fetch failure)' do
      expect(described_class.call('東京都千代田区')).to(be_nil)
    end

    it 'raises NormalizeError from call!' do
      expect { described_class.call!('東京都千代田区') }
        .to(raise_error(::JapaneseAddressParser::NormalizeError))
    end
  end

  it 'resolves to level 8 (rsdt) through file://' do
    expect(described_class.call('渋谷区道玄坂1-10-8')).to(match_close_to(pref: '東京都', city: '渋谷区', town: '道玄坂一丁目', level: 8))
  end
end
