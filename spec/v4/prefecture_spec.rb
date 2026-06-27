# frozen_string_literal: true

require 'japanese_address_parser/v4/prefecture'

::RSpec.describe(::JapaneseAddressParser::V4::Prefecture) do
  describe '.from_metadata' do
    context 'with nil (prefecture not detected)' do
      it 'returns nil' do
        expect(described_class.from_metadata(nil)).to(be_nil)
      end
    end

    context 'with a metadata hash (Symbol keys, point [lng, lat])' do
      subject(:prefecture) { described_class.from_metadata(hash) }

      let(:hash) do
        { code: 13, pref: '東京都', pref_k: 'トウキョウト', pref_r: 'Tokyo', point: [139.691722, 35.689501] }
      end

      it 'maps name/code/kana/romaji' do
        expect(prefecture.name).to(eq('東京都'))
        expect(prefecture.code).to(eq(13))
        expect(prefecture.name_kana).to(eq('トウキョウト'))
        expect(prefecture.name_romaji).to(eq('Tokyo'))
      end

      it 'builds a level-1 representative point with lat/lng swapped from [lng, lat]' do
        expect(prefecture.point.lat).to(eq(35.689501))
        expect(prefecture.point.lng).to(eq(139.691722))
        expect(prefecture.point.level).to(eq(1))
      end
    end
  end

  describe '#to_h' do
    it 'deep-converts the nested point' do
      prefecture = described_class.from_metadata({ code: 13, pref: '東京都', pref_k: 'トウキョウト', pref_r: 'Tokyo', point: [139.691722, 35.689501] })

      expect(prefecture.to_h).to(eq(name: '東京都', code: 13, name_kana: 'トウキョウト', name_romaji: 'Tokyo', point: { lat: 35.689501, lng: 139.691722, level: 1 }))
    end
  end
end
