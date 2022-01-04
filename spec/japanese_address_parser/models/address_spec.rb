# frozen_string_literal: true

require_relative '../../../lib/japanese_address_parser/models/address'

::RSpec.describe(::JapaneseAddressParser::Models::Address) do
  describe '#furigana' do
    subject { address.furigana }

    context '都道府県がみつからないとき' do
      let(:address) { build(:address, prefecture: nil, city: nil, town: nil) }

      it { is_expected.to(eq('')) }
    end

    context '市区町村が見つからないとき' do
      let(:prefecture) { build(:prefecture, name: '東京都', name_kana: 'トウキョウト') }
      let(:address) { build(:address, prefecture: prefecture, city: nil, town: nil) }

      it { is_expected.to(eq('トウキョウト')) }
    end

    context '町が見つからないとき' do
      let(:prefecture) { build(:prefecture, name: '東京都', name_kana: 'トウキョウト') }
      let(:city)    { build(:city, name: '港区', name_kana: 'ミナトク')                    }
      let(:address) { build(:address, prefecture: prefecture, city: city, town: nil) }

      it { is_expected.to(eq('トウキョウトミナトク')) }
    end

    context '町まで見つかるとき' do
      let(:prefecture) { build(:prefecture, name: '東京都', name_kana: 'トウキョウト') }
      let(:city)    { build(:city, name: '港区', name_kana: 'ミナトク')                     }
      let(:town)    { build(:town, name: '芝公園四丁目', name_kana: 'シバコウエン 4')             }
      let(:address) { build(:address, prefecture: prefecture, city: city, town: town) }

      it { is_expected.to(eq('トウキョウトミナトクシバコウエン 4')) }
    end
  end
end
