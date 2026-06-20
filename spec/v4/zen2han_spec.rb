# frozen_string_literal: true

require 'japanese_address_parser/v4/zen2han'

::RSpec.describe(::JapaneseAddressParser::V4::Zen2han) do
  describe '.call' do
    it 'converts full-width uppercase letters to half-width' do
      expect(described_class.call('ＡＢＣＸＹＺ')).to(eq('ABCXYZ'))
    end

    it 'converts full-width lowercase letters to half-width' do
      expect(described_class.call('ａｂｃｘｙｚ')).to(eq('abcxyz'))
    end

    it 'converts full-width digits to half-width' do
      expect(described_class.call('０１２３４５６７８９')).to(eq('0123456789'))
    end

    it 'converts the boundary characters of each range' do
      expect(described_class.call('ＡＺａｚ０９')).to(eq('AZaz09'))
    end

    it 'converts only full-width alnum and leaves other characters untouched' do
      expect(described_class.call('東京都Ａ１丁目')).to(eq('東京都A1丁目'))
    end

    it 'leaves a string without full-width alnum unchanged' do
      expect(described_class.call('東京都渋谷区')).to(eq('東京都渋谷区'))
    end

    it 'returns an empty string for an empty input' do
      expect(described_class.call('')).to(eq(''))
    end
  end
end
