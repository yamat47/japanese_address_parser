# frozen_string_literal: true

require_relative '../../../lib/japanese_address_parser/address_parser/pattern_creator'

::RSpec.describe(::JapaneseAddressParser::AddressParser::PatternCreator) do
  describe '.call' do
    context '表記揺れを含みそうな地名のとき' do
      it 'どの表記でも一致する正規表現を作る' do
        expect(described_class.call('三栄町')).to(match('三栄町'))
        expect(described_class.call('三栄町')).to(match('三栄町'))
        expect(described_class.call('四谷三栄町')).to(match('四谷三栄町'))
        expect(described_class.call('四谷三栄町')).to(match('四谷三栄町'))

        expect(described_class.call('鬮野川')).to(match('鬮野川'))
        expect(described_class.call('鬮野川')).to(match('くじ野川'))
        expect(described_class.call('鬮野川')).to(match('くじの川'))
        expect(described_class.call('くじ野川')).to(match('鬮野川'))
        expect(described_class.call('くじ野川')).to(match('くじ野川'))
        expect(described_class.call('くじ野川')).to(match('くじの川'))
        expect(described_class.call('くじの川')).to(match('鬮野川'))
        expect(described_class.call('くじの川')).to(match('くじ野川'))
        expect(described_class.call('くじの川')).to(match('くじの川'))

        expect(described_class.call('通り')).to(match('通り'))
        expect(described_class.call('通り')).to(match('とおり'))
        expect(described_class.call('とおり')).to(match('通り'))
        expect(described_class.call('とおり')).to(match('とおり'))

        expect(described_class.call('埠頭')).to(match('埠頭'))
        expect(described_class.call('埠頭')).to(match('ふ頭'))
        expect(described_class.call('ふ頭')).to(match('埠頭'))
        expect(described_class.call('ふ頭')).to(match('ふ頭'))

        expect(described_class.call('番町')).to(match('番町'))
        expect(described_class.call('番町')).to(match('番丁'))
        expect(described_class.call('番丁')).to(match('番町'))
        expect(described_class.call('番丁')).to(match('番丁'))

        expect(described_class.call('穝')).to(match('穝'))
        expect(described_class.call('穝')).to(match('さい'))
        expect(described_class.call('さい')).to(match('穝'))
        expect(described_class.call('さい')).to(match('さい'))

        expect(described_class.call('杁')).to(match('杁'))
        expect(described_class.call('杁')).to(match('えぶり'))
        expect(described_class.call('えぶり')).to(match('杁'))
        expect(described_class.call('えぶり')).to(match('えぶり'))

        expect(described_class.call('薭')).to(match('薭'))
        expect(described_class.call('薭')).to(match('稗'))
        expect(described_class.call('薭')).to(match('ひえ'))
        expect(described_class.call('薭')).to(match('ヒエ'))
        expect(described_class.call('稗')).to(match('薭'))
        expect(described_class.call('稗')).to(match('稗'))
        expect(described_class.call('稗')).to(match('ひえ'))
        expect(described_class.call('稗')).to(match('ヒエ'))
        expect(described_class.call('ひえ')).to(match('薭'))
        expect(described_class.call('ひえ')).to(match('稗'))
        expect(described_class.call('ひえ')).to(match('ひえ'))
        expect(described_class.call('ひえ')).to(match('ヒエ'))
        expect(described_class.call('ヒエ')).to(match('薭'))
        expect(described_class.call('ヒエ')).to(match('稗'))
        expect(described_class.call('ヒエ')).to(match('ひえ'))
        expect(described_class.call('ヒエ')).to(match('ヒエ'))

        expect(described_class.call('之')).to(match('之'))
        expect(described_class.call('之')).to(match('ノ'))
        expect(described_class.call('之')).to(match('の'))
        expect(described_class.call('ノ')).to(match('之'))
        expect(described_class.call('ノ')).to(match('ノ'))
        expect(described_class.call('ノ')).to(match('の'))
        expect(described_class.call('の')).to(match('之'))
        expect(described_class.call('の')).to(match('ノ'))
        expect(described_class.call('の')).to(match('の'))

        expect(described_class.call('ヶ')).to(match('ヶ'))
        expect(described_class.call('ヶ')).to(match('ケ'))
        expect(described_class.call('ヶ')).to(match('が'))
        expect(described_class.call('ケ')).to(match('ヶ'))
        expect(described_class.call('ケ')).to(match('ケ'))
        expect(described_class.call('ケ')).to(match('が'))
        expect(described_class.call('が')).to(match('ヶ'))
        expect(described_class.call('が')).to(match('ケ'))
        expect(described_class.call('が')).to(match('が'))

        expect(described_class.call('ヵ')).to(match('ヵ'))
        expect(described_class.call('ヵ')).to(match('カ'))
        expect(described_class.call('ヵ')).to(match('か'))
        expect(described_class.call('ヵ')).to(match('力'))
        expect(described_class.call('カ')).to(match('ヵ'))
        expect(described_class.call('カ')).to(match('カ'))
        expect(described_class.call('カ')).to(match('か'))
        expect(described_class.call('カ')).to(match('力'))
        expect(described_class.call('か')).to(match('ヵ'))
        expect(described_class.call('か')).to(match('カ'))
        expect(described_class.call('か')).to(match('か'))
        expect(described_class.call('か')).to(match('力'))
        expect(described_class.call('力')).to(match('ヵ'))
        expect(described_class.call('力')).to(match('カ'))
        expect(described_class.call('力')).to(match('か'))
        expect(described_class.call('力')).to(match('力'))

        expect(described_class.call('ッ')).to(match('ッ'))
        expect(described_class.call('ッ')).to(match('ツ'))
        expect(described_class.call('ッ')).to(match('っ'))
        expect(described_class.call('ッ')).to(match('つ'))

        expect(described_class.call('ニ')).to(match('ニ'))
        expect(described_class.call('ニ')).to(match('二'))
        expect(described_class.call('二')).to(match('ニ'))
        expect(described_class.call('二')).to(match('二'))

        expect(described_class.call('ハ')).to(match('ハ'))
        expect(described_class.call('ハ')).to(match('八'))
        expect(described_class.call('八')).to(match('ハ'))
        expect(described_class.call('八')).to(match('八'))

        expect(described_class.call('塚')).to(match('塚'))
        expect(described_class.call('塚')).to(match('塚'))
        expect(described_class.call('塚')).to(match('塚'))
        expect(described_class.call('塚')).to(match('塚'))

        expect(described_class.call('釜')).to(match('釜'))
        expect(described_class.call('釜')).to(match('竈'))
        expect(described_class.call('竈')).to(match('釜'))
        expect(described_class.call('竈')).to(match('竈'))

        expect(described_class.call('條')).to(match('條'))
        expect(described_class.call('條')).to(match('条'))
        expect(described_class.call('条')).to(match('條'))
        expect(described_class.call('条')).to(match('条'))

        expect(described_class.call('狛')).to(match('狛'))
        expect(described_class.call('狛')).to(match('拍'))
        expect(described_class.call('拍')).to(match('狛'))
        expect(described_class.call('拍')).to(match('拍'))

        expect(described_class.call('藪')).to(match('藪'))
        expect(described_class.call('藪')).to(match('薮'))
        expect(described_class.call('薮')).to(match('藪'))
        expect(described_class.call('薮')).to(match('薮'))

        expect(described_class.call('渕')).to(match('渕'))
        expect(described_class.call('渕')).to(match('淵'))
        expect(described_class.call('淵')).to(match('渕'))
        expect(described_class.call('淵')).to(match('淵'))

        expect(described_class.call('エ')).to(match('エ'))
        expect(described_class.call('エ')).to(match('ヱ'))
        expect(described_class.call('エ')).to(match('え'))
        expect(described_class.call('ヱ')).to(match('エ'))
        expect(described_class.call('ヱ')).to(match('ヱ'))
        expect(described_class.call('ヱ')).to(match('え'))
        expect(described_class.call('え')).to(match('エ'))
        expect(described_class.call('え')).to(match('ヱ'))
        expect(described_class.call('え')).to(match('え'))

        expect(described_class.call('曾')).to(match('曾'))
        expect(described_class.call('曾')).to(match('曽'))
        expect(described_class.call('曽')).to(match('曾'))
        expect(described_class.call('曽')).to(match('曽'))

        expect(described_class.call('舟')).to(match('舟'))
        expect(described_class.call('舟')).to(match('船'))
        expect(described_class.call('船')).to(match('舟'))
        expect(described_class.call('船')).to(match('船'))

        expect(described_class.call('莵')).to(match('莵'))
        expect(described_class.call('莵')).to(match('菟'))
        expect(described_class.call('菟')).to(match('莵'))
        expect(described_class.call('菟')).to(match('菟'))

        expect(described_class.call('市')).to(match('市'))
        expect(described_class.call('市')).to(match('巿'))
        expect(described_class.call('巿')).to(match('市'))
        expect(described_class.call('巿')).to(match('巿'))
      end
    end

    context '丁目を含みそうな地名のとき' do
      it '丁目を含むときと含まないときの両方に一致する正規表現を作る' do
        expect(described_class.call('日本大通1')).to(match('日本大通'))
        expect(described_class.call('日本大通1')).to(match('日本大通一丁目'))

        expect(described_class.call('芝公園4-2-8')).to(match('芝公園'))
        expect(described_class.call('芝公園4-2-8')).to(match('芝公園四丁目'))
      end
    end
  end
end
