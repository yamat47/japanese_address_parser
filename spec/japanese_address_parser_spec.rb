# frozen_string_literal: true

require_relative 'support/yaml_loader'

::RSpec.describe(::JapaneseAddressParser) do
  describe '.call' do
    context '町域が含まれていないとき' do
      it '市区町村まで解析できる' do
        parsed_address = described_class.call('東京都北区')

        expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
        expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
        expect(parsed_address.town).to(be_nil)
        expect(parsed_address.furigana).to(eq('トウキョウトキタク'))
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/parsable_to_prefecture_addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '都道府県まで解析できる' do
          parsed_address = described_class.call(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_nil)
          expect(parsed_address.town).to(be_nil)
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/parsable_to_city_addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '市区町村まで解析できる' do
          parsed_address = described_class.call(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(parsed_address.town).to(be_nil)
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '町域まで解析できる' do
          parsed_address = described_class.call(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(parsed_address.town).to(be_a(::JapaneseAddressParser::Models::Town))
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    context 'Schmoozerが例外を吐いたとき' do
      before do
        allow(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer).to(receive(:call).and_raise(::Schmooze::JavaScript::FetchError))
      end

      specify 'nilを返すこと' do
        expect(described_class.call('東京都渋谷区恵比寿1-1-1')).to(be_nil)
      end
    end
  end

  describe '.call!' do
    context '町域が含まれていないとき' do
      it '市区町村まで解析できる' do
        parsed_address = described_class.call!('東京都北区')

        expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
        expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
        expect(parsed_address.town).to(be_nil)
        expect(parsed_address.furigana).to(eq('トウキョウトキタク'))
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/parsable_to_prefecture_addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '都道府県まで解析できる' do
          parsed_address = described_class.call!(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_nil)
          expect(parsed_address.town).to(be_nil)
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/parsable_to_city_addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '市区町村まで解析できる' do
          parsed_address = described_class.call!(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(parsed_address.town).to(be_nil)
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    ::YamlLoader.slice_load('spec/japanese_address_parser_spec/addresses.yml').each do |address|
      context "#{address['full_address']}のとき" do
        it '町域まで解析できる' do
          parsed_address = described_class.call!(address['full_address'])

          expect(parsed_address).to(be_a(::JapaneseAddressParser::Models::Address))
          expect(parsed_address.prefecture).to(be_a(::JapaneseAddressParser::Models::Prefecture))
          expect(parsed_address.city).to(be_a(::JapaneseAddressParser::Models::City))
          expect(parsed_address.town).to(be_a(::JapaneseAddressParser::Models::Town))
          expect(parsed_address.furigana).to(eq(address['furigana']))
        end
      end
    end

    context 'Schmoozerが例外を吐いたとき' do
      before do
        allow(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer).to(receive(:call).and_raise(::Schmooze::JavaScript::FetchError))
      end

      specify '::JapaneseAddressParser::NormalizeErrorを吐くこと' do
        expect { described_class.call!('東京都渋谷区恵比寿1-1-1') }
          .to(raise_error(::JapaneseAddressParser::NormalizeError))
      end
    end
  end
end
