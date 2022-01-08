# frozen_string_literal: true

require 'yaml'

::RSpec.describe(::JapaneseAddressParser) do
  describe '.call' do
    subject(:parsed_address) { described_class.call(full_address) }

    context '町域が含まれていないとき' do
      let(:full_address) { '東京都北区' }

      it '市区町村まで解析できる' do
        expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
        expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
        expect(parsed_address.town).to(be_nil)
        expect(parsed_address.furigana).to(eq('トウキョウトキタク'))
      end
    end

    ::YAML.load_file('spec/addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        let(:full_address) { address['full_address'] }
        let(:furigana)     { address['furigana']     }

        it '町名まで解析できる' do
          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(parsed_address.town).to(be_a(::JapaneseAddressParser::Models::Town))
          expect(parsed_address.furigana).to(eq(furigana))
        end
      end
    end
  end
end
