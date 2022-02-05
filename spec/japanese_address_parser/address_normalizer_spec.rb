# frozen_string_literal: true

::RSpec.describe(::JapaneseAddressParser::AddressNormalizer) do
  describe '.call' do
    context 'Schmoozerが正常に動いているとき' do
      specify '住所を解析できること' do
        result = described_class.call('東京都渋谷区恵比寿1-1-1')
        expect(result).to(include('pref' => '東京都', 'city' => '渋谷区', 'town' => '恵比寿一丁目'))
      end
    end

    context 'Schmoozerが例外を吐いたとき' do
      before do
        allow(::JapaneseAddressParser::AddressNormalizer::NormalizeJapaneseAddressesSchmoozer).to(receive(:call).and_raise(::Schmooze::JavaScript::FetchError))
      end

      specify '::JapaneseAddressParser::NormalizeErrorを吐くこと' do
        expect { described_class.call('東京都渋谷区恵比寿1-1-1') }
          .to(raise_error(::JapaneseAddressParser::NormalizeError))
      end
    end
  end
end
