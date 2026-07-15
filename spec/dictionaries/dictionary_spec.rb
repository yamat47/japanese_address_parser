# frozen_string_literal: true

require 'japanese_address_parser/dictionaries/dictionary'
require 'japanese_address_parser/dictionaries/jis_dai2'

::RSpec.describe(::JapaneseAddressParser::Dictionaries::Dictionary) do
  describe 'DICTIONARY' do
    # 現状は jisDai2Dictionary 1 本を flat 化しただけ（将来辞書を増やすためのフック）。
    it 'aggregates the jisDai2 dictionary as-is' do
      expect(described_class::DICTIONARY).to(eq(::JapaneseAddressParser::Dictionaries::JisDai2::DICTIONARY))
    end
  end
end
