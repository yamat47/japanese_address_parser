# frozen_string_literal: true

require 'japanese_address_parser/data/single_rsdt'

::RSpec.describe(::JapaneseAddressParser::Data::SingleRsdt) do
  describe '.from_json' do
    it 'maps present fields and leaves absent optionals nil' do
      rsdt = described_class.from_json('rsdt_num' => '8', 'point' => [139.6967, 35.6586])
      expect(rsdt).to(have_attributes(blk_num: nil, rsdt_num: '8', rsdt_num2: nil, point: [139.6967, 35.6586]))
    end

    it 'retains the block number and second residence number' do
      rsdt = described_class.from_json('blk_num' => '10', 'rsdt_num' => '8', 'rsdt_num2' => '2')
      expect(rsdt).to(have_attributes(blk_num: '10', rsdt_num: '8', rsdt_num2: '2'))
    end
  end

  describe '#rsdt_to_string' do
    it 'joins block number, residence number and second residence number with "-"' do
      rsdt = described_class.new(blk_num: '10', rsdt_num: '8', rsdt_num2: '2', point: nil)
      expect(rsdt.rsdt_to_string).to(eq('10-8-2'))
    end

    it 'drops nil parts (JS filter(Boolean))' do
      rsdt = described_class.new(blk_num: nil, rsdt_num: '8', rsdt_num2: nil, point: nil)
      expect(rsdt.rsdt_to_string).to(eq('8'))
    end

    # JS の filter(Boolean) は空文字も除外する。Ruby では "" は truthy なので compact では
    # 落ちず、忠実移植のために明示的に除外している（upstream_mapping.md §2 の compact 案との差異）。
    it 'drops empty-string parts as JS filter(Boolean) does (not merely nil)' do
      rsdt = described_class.new(blk_num: '', rsdt_num: '8', rsdt_num2: '', point: nil)
      expect(rsdt.rsdt_to_string).to(eq('8'))
    end
  end
end
