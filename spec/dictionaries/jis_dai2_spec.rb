# frozen_string_literal: true

require 'japanese_address_parser/dictionaries/jis_dai2'

::RSpec.describe(::JapaneseAddressParser::Dictionaries::JisDai2) do
  describe 'DICTIONARY' do
    subject(:dictionary) { described_class::DICTIONARY }

    it 'ports every upstream entry' do
      expect(dictionary.size).to(eq(290))
    end

    it 'preserves the upstream order at the boundaries' do
      expect(dictionary.first).to(eq({ src: '亞', dst: '亜' }))
      expect(dictionary.last).to(eq({ src: '驒', dst: '騨' }))
    end

    it 'maps an old-form (JIS level 2) character to its new form' do
      expect(dictionary).to(include({ src: '區', dst: '区' }))
    end
  end
end
