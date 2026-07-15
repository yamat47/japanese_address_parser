# frozen_string_literal: true

require 'japanese_address_parser/town'

::RSpec.describe(::JapaneseAddressParser::Town) do
  describe '.from_metadata' do
    context 'with nil (town not detected)' do
      it 'returns nil' do
        expect(described_class.from_metadata(nil)).to(be_nil)
      end
    end

    context 'with a chome (point present)' do
      subject(:town) { described_class.from_metadata(hash) }

      let(:hash) do
        {
          machiaza_id: '0001001',
          oaza_cho: '大豆戸町',
          oaza_cho_k: 'マメドチョウ',
          oaza_cho_r: 'Mamedocho',
          chome: '一丁目',
          chome_n: 1,
          koaza: nil,
          rsdt: nil,
          point: [139.631, 35.508]
        }
      end

      it 'composes name (machiAzaName) and keeps both chome and chome_n' do
        expect(town.name).to(eq('大豆戸町一丁目'))
        expect(town.machiaza_id).to(eq('0001001'))
        expect(town.chome).to(eq('一丁目'))
        expect(town.chome_n).to(eq(1))
        expect(town.koaza).to(be_nil)
      end

      it 'builds a level-3 representative point with lat/lng swapped from [lng, lat]' do
        expect(town.point.lat).to(eq(35.508))
        expect(town.point.lng).to(eq(139.631))
        expect(town.point.level).to(eq(3))
      end
    end

    context 'without a point' do
      subject(:town) { described_class.from_metadata(hash) }

      let(:hash) do
        { machiaza_id: '0002000', oaza_cho: '本町', chome: nil, chome_n: nil, koaza: nil, point: nil }
      end

      it 'leaves point nil' do
        expect(town.name).to(eq('本町'))
        expect(town.point).to(be_nil)
      end
    end
  end

  describe '#to_h' do
    it 'deep-converts the nested point' do
      town = described_class.from_metadata({ machiaza_id: '0001001', oaza_cho: '大豆戸町', chome: '一丁目', chome_n: 1, koaza: nil, point: [139.631, 35.508] })

      expect(town.to_h).to(eq(name: '大豆戸町一丁目', machiaza_id: '0001001', chome: '一丁目', chome_n: 1, koaza: nil, point: { lat: 35.508, lng: 139.631, level: 3 }))
    end
  end
end
