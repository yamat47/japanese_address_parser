# frozen_string_literal: true

require 'japanese_address_parser/data/single_chiban'

::RSpec.describe(::JapaneseAddressParser::Data::SingleChiban) do
  describe '.from_json' do
    it 'maps present fields and leaves absent optionals nil' do
      chiban = described_class.from_json('prc_num1' => '1', 'point' => [139.6967, 35.6586])
      expect(chiban).to(have_attributes(prc_num1: '1', prc_num2: nil, prc_num3: nil, point: [139.6967, 35.6586]))
    end

    it 'retains the second and third parcel numbers' do
      chiban = described_class.from_json('prc_num1' => '1', 'prc_num2' => '2', 'prc_num3' => '3')
      expect(chiban).to(have_attributes(prc_num1: '1', prc_num2: '2', prc_num3: '3'))
    end
  end

  describe '#chiban_to_string' do
    it 'joins the three parcel numbers with "-"' do
      chiban = described_class.new(prc_num1: '1', prc_num2: '2', prc_num3: '3', point: nil)
      expect(chiban.chiban_to_string).to(eq('1-2-3'))
    end

    it 'drops nil parts (JS filter(Boolean))' do
      chiban = described_class.new(prc_num1: '1', prc_num2: nil, prc_num3: nil, point: nil)
      expect(chiban.chiban_to_string).to(eq('1'))
    end

    # JS の filter(Boolean) は空文字も除外する。Ruby では "" は truthy なので compact では
    # 落ちず、忠実移植のために明示的に除外している（upstream_mapping.md §2 の compact 案との差異）。
    it 'drops empty-string parts as JS filter(Boolean) does (not merely nil)' do
      chiban = described_class.new(prc_num1: '1', prc_num2: '', prc_num3: '3', point: nil)
      expect(chiban.chiban_to_string).to(eq('1-3'))
    end
  end
end
