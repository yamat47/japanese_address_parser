# frozen_string_literal: true

require 'japanese_address_parser/v4/dictionaries/dictionary'
require 'japanese_address_parser/v4/dictionaries/jis_dai2'

::RSpec.describe(::JapaneseAddressParser::V4::Dictionaries::Dictionary) do
  describe 'DICTIONARY' do
    # 現状は jisDai2Dictionary 1 本を flat 化しただけ（将来辞書を増やすためのフック）。
    it 'aggregates the jisDai2 dictionary as-is' do
      expect(described_class::DICTIONARY).to(eq(::JapaneseAddressParser::V4::Dictionaries::JisDai2::DICTIONARY))
    end
  end
end
