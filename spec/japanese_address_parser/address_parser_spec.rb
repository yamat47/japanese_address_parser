# frozen_string_literal: true

require_relative '../../lib/japanese_address_parser/address_parser'

::RSpec.describe(::JapaneseAddressParser::AddressParser) do
  describe '.call' do
    context '都道府県がみつからないとき' do
      it '中身が空のAddressオブジェクトを返す' do
        address = described_class.call('武蔵国港区芝公園4-2-8')

        expect(address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(address.full_address).to(eq('武蔵国港区芝公園4-2-8'))
        expect(address.prefecture).to(be_nil)
        expect(address.city).to(be_nil)
        expect(address.town).to(be_nil)
      end
    end

    context '市区町村が見つからないとき' do
      it '都道府県だけ入ったAddressオブジェクトを返す' do
        address = described_class.call('東京都港南区芝公園4-2-8')

        expect(address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(address.full_address).to(eq('東京都港南区芝公園4-2-8'))
        expect(address.prefecture.name).to(eq('東京都'))
        expect(address.city).to(be_nil)
        expect(address.town).to(be_nil)
      end
    end

    context '町が見つからないとき' do
      it '都道府県と市区町村だけ入ったAddressオブジェクトを返す' do
        address = described_class.call('東京都港区北芝公園4-2-8')

        expect(address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(address.full_address).to(eq('東京都港区北芝公園4-2-8'))
        expect(address.prefecture.name).to(eq('東京都'))
        expect(address.city.name).to(eq('港区'))
        expect(address.town).to(be_nil)
      end
    end

    context '町まで見つかるとき' do
      it '町まで入ったAddressオブジェクトを返す' do
        address = described_class.call('東京都港区芝公園4-2-8')

        expect(address).to(be_a(::JapaneseAddressParser::Models::Address))
        expect(address.full_address).to(eq('東京都港区芝公園4-2-8'))
        expect(address.prefecture.name).to(eq('東京都'))
        expect(address.city.name).to(eq('港区'))
        expect(address.town.name).to(eq('芝公園四丁目'))
      end
    end
  end
end
