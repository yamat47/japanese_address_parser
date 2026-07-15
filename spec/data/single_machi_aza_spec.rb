# frozen_string_literal: true

require 'json'
require 'pathname'
require 'japanese_address_parser/data/single_machi_aza'

::RSpec.describe(::JapaneseAddressParser::Data::SingleMachiAza) do
  let(:fixture) do
    path = ::Pathname.new(__dir__).join('../fixtures/data/machi_aza_slice.json')
    ::JSON.parse(path.read)
  end
  let(:entries) { fixture['data'] }
  # 0: 神宮前一丁目 (oaza+chome, rsdt, point, csv_ranges 両方)
  # 1: 旭川清澄町 (oaza only, rsdt, point, csv_ranges 地番のみ)
  # 2: 新屋町字後田 (oaza+koaza, point なし, csv_ranges 地番のみ)
  # 3: クネソエ (koaza only, point あり, csv_ranges/rsdt なし)

  describe '.from_json' do
    subject(:machi_aza) { described_class.from_json(entries[0]) }

    it 'maps the scalar fields including the integer chome_n' do
      expect(machi_aza).to(have_attributes(machiaza_id: '0001001', oaza_cho: '神宮前', oaza_cho_k: 'ジングウマエ', oaza_cho_r: 'Jingumae', chome: '一丁目', chome_n: 1, rsdt: true, point: [139.705302, 35.671552]))
    end

    it 'preserves csv_ranges verbatim (both 住居表示 and 地番) for level 8' do
      expect(machi_aza.csv_ranges).to(eq('地番' => { 'start' => 50_000, 'length' => 14_823 }, '住居表示' => { 'start' => 50_000, 'length' => 18_985 }))
    end

    it 'leaves absent optional fields nil' do
      machi_aza = described_class.from_json(entries[3])
      expect(machi_aza).to(have_attributes(oaza_cho: nil, oaza_cho_k: nil, chome: nil, chome_n: nil, koaza: 'クネソエ', rsdt: nil, csv_ranges: nil))
    end

    it 'keeps a csv_ranges that only carries 地番' do
      machi_aza = described_class.from_json(entries[1])
      expect(machi_aza.csv_ranges).to(eq('地番' => { 'start' => 100_000, 'length' => 3191 }))
    end
  end

  describe '#machi_aza_name' do
    it 'joins oaza_cho and chome (JS machiAzaName: oaza_cho + chome + koaza)' do
      expect(described_class.from_json(entries[0]).machi_aza_name).to(eq('神宮前一丁目'))
    end

    it 'returns just the oaza_cho when there is no chome or koaza' do
      expect(described_class.from_json(entries[1]).machi_aza_name).to(eq('旭川清澄町'))
    end

    it 'appends the koaza after the oaza_cho' do
      expect(described_class.from_json(entries[2]).machi_aza_name).to(eq('新屋町字後田'))
    end

    it 'returns just the koaza when there is no oaza_cho' do
      expect(described_class.from_json(entries[3]).machi_aza_name).to(eq('クネソエ'))
    end
  end
end
