# frozen_string_literal: true

require 'json'
require 'pathname'
require 'japanese_address_parser/v4/data/single_prefecture'

::RSpec.describe(::JapaneseAddressParser::V4::Data::SinglePrefecture) do
  let(:fixture) do
    path = ::Pathname.new(__dir__).join('../fixtures/data/ja_slice.json')
    ::JSON.parse(path.read)
  end
  let(:hokkaido_hash) { fixture['data'].first }

  describe '.from_json' do
    subject(:prefecture) { described_class.from_json(hokkaido_hash) }

    it 'maps the scalar fields' do
      expect(prefecture).to(have_attributes(code: 10_006, pref: '北海道', pref_k: 'ホッカイドウ', pref_r: 'Hokkaido', point: [141.347906782, 43.0639406375]))
    end

    it 'converts each city into a SingleCity' do
      expect(prefecture.cities).to(all(be_a(::JapaneseAddressParser::V4::Data::SingleCity)))
      expect(prefecture.cities.map(&:city_name)).to(eq(%w[札幌市中央区 函館市 石狩郡当別町]))
    end

    it 'defaults cities to an empty array when absent' do
      prefecture = described_class.from_json('code' => 1, 'pref' => '東京都')
      expect(prefecture.cities).to(eq([]))
    end
  end

  describe '#prefecture_name' do
    it 'returns the pref field (JS prefectureName)' do
      expect(described_class.from_json(hokkaido_hash).prefecture_name).to(eq('北海道'))
    end
  end
end
