# frozen_string_literal: true

require 'yaml'

::RSpec.describe(::JapaneseAddressParser) do
  describe '.call' do
    subject { described_class.call(full_address) }

    ::YAML.load_file('spec/addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        let(:full_address) { address['full_address'] }
        let(:furigana)     { address['furigana'] }

        it '町名まで解析できる' do
          expect(subject).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(subject.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(subject.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(subject.town).to(be_a(::JapaneseAddressParser::Models::Town))
          expect(subject.furigana).to(eq(furigana))
        end
      end
    end
  end
end
