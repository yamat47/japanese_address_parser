# frozen_string_literal: true

require 'japanese_address_parser/v4/cache_regexes'

# 上流（main.test.ts）同様、既定エンドポイント＝ライブ CDN を叩く（working_agreement §1-8）。
# モジュールのキャッシュはスイート内で共有してネットワーク呼び出しを抑える。
::RSpec.describe(::JapaneseAddressParser::V4::CacheRegexes, :upstream_port) do
  let(:api) { described_class.get_prefectures }
  let(:kanagawa) do
    described_class.get_prefecture_regex_patterns(api).find { |pref, _| pref.pref == '神奈川県' }
                   .first
  end
  let(:kohoku) do
    described_class.get_city_regex_patterns(kanagawa).find { |city, _| city.city_name == '横浜市港北区' }
                   .first
  end

  describe '.get_prefectures' do
    it 'fetches all 47 prefectures as a PrefectureApi' do
      expect(api).to(be_a(::JapaneseAddressParser::V4::Data::PrefectureApi))
      expect(api.data.size).to(eq(47))
    end
  end

  describe '.get_prefecture_regex_patterns' do
    subject(:pattern) do
      described_class.get_prefecture_regex_patterns(api).find { |pref, _| pref.pref == '神奈川県' }
                     .last
    end

    it 'anchors with \\A and tolerates the omitted 都道府県 suffix' do
      expect(pattern).to(eq('\A神奈川(都|道|府|県)?'))
      expect('神奈川県横浜市港北区'.match?(/#{pattern}/)).to(be(true))
      expect('神奈川横浜市港北区'.match?(/#{pattern}/)).to(be(true))
    end
  end

  describe '.get_city_regex_patterns' do
    subject(:pattern) do
      described_class.get_city_regex_patterns(kanagawa).find { |city, _| city.city_name == '横浜市港北区' }
                     .last
    end

    it 'applies the dictionary conversion and matches the city' do
      # 浜→(濱|浜)・市→(市|巿)・区→(區|区) のように両字体へ展開される
      expect(pattern).to(start_with('\A横'))
      expect('横浜市港北区大豆戸町'.match?(/#{pattern}/)).to(be(true))
    end
  end

  describe '.get_towns' do
    it 'fetches the town list as a MachiAzaApi' do
      towns = described_class.get_towns(kanagawa, kohoku, api.meta.updated)

      expect(towns).to(be_a(::JapaneseAddressParser::V4::Data::MachiAzaApi))
      expect(towns.data).not_to(be_empty)
    end
  end

  describe '.get_town_regex_patterns' do
    subject(:patterns) { described_class.get_town_regex_patterns(kanagawa, kohoku, api.meta.updated) }

    it 'generates a pattern that matches a representative address to its town' do
      hit = patterns.find { |_, pat| '大豆戸町17番地11'.match?(/#{pat}/) }

      expect(hit).not_to(be_nil)
      expect(hit.first.machi_aza_name).to(include('大豆戸'))
    end

    it 'produces only valid regexes' do
      expect(patterns).to(all(satisfy { |_, pat| ::Regexp.new(pat) }))
    end

    it 'caches the result (returns the same object on repeated calls)' do
      first = described_class.get_town_regex_patterns(kanagawa, kohoku, api.meta.updated)

      expect(described_class.get_town_regex_patterns(kanagawa, kohoku, api.meta.updated)).to(be(first))
    end
  end

  describe '.cache' do
    it 'is an LruRedux cache that evicts at config.cache_size' do
      ::JapaneseAddressParser::V4.instance_variable_set(:@config, nil)
      ::JapaneseAddressParser::V4.configure { |c| c.cache_size = 2 }
      described_class.instance_variable_set(:@cache, nil)

      cache = described_class.cache
      expect(cache).to(be_a(::LruRedux::Cache))
      cache[:a] = 1
      cache[:b] = 2
      # :c の追加で最古の :a が evict される
      cache[:c] = 3

      expect(cache.count).to(eq(2))
      expect(cache.key?(:a)).to(be(false))
    ensure
      described_class.instance_variable_set(:@cache, nil)
      ::JapaneseAddressParser::V4.instance_variable_set(:@config, nil)
    end
  end

  describe '.get_same_named_prefecture_city_regex_patterns' do
    it 'pairs a label with a \\A-anchored city pattern when a city starts with a prefecture name' do
      patterns = described_class.get_same_named_prefecture_city_regex_patterns(api)

      expect(patterns).to(include(['青森県青森市', '\A青森市']))
    end
  end

  describe '.get_rsdt / .get_chiban (M8 stubs)' do
    it 'raises NotImplementedError until M8' do
      expect { described_class.get_rsdt(nil, nil, nil, nil) }
        .to(raise_error(::NotImplementedError))
      expect { described_class.get_chiban(nil, nil, nil, nil) }
        .to(raise_error(::NotImplementedError))
    end
  end
end
