# frozen_string_literal: true

require 'rspec'
require_relative '../../../lib/japanese_address_parser/normalizers/pure_ruby'

::RSpec.describe(::JapaneseAddressParser::Normalizers::PureRuby) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '基本的な正規化' do
      let(:input) { '東京都　港区　芝１－２－３' }

      it { is_expected.to(eq('東京都 港区 芝1-2-3')) }
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    context 'nilの場合' do
      let(:input) { nil }

      it { is_expected.to(eq('')) }
    end
  end

  describe '.remove_spaces_before_town' do
    subject { described_class.remove_spaces_before_town(input) }

    context '町丁目名より前にスペースがある場合' do
      let(:input) { '東京都 港区 芝 1丁目' }

      it { is_expected.to(eq('東京都港区芝1丁目')) }
    end

    context '番地表記の場合' do
      let(:input) { '東京都 港区 芝 15番地' }

      it { is_expected.to(eq('東京都港区芝15番地')) }
    end

    context '条表記の場合' do
      let(:input) { '北海道 札幌市 中央区 南3条' }

      it { is_expected.to(eq('北海道札幌市中央区南3条')) }
    end

    context '町丁目名がない場合' do
      let(:input) { '東京都 港区 芝公園' }

      it { is_expected.to(eq('東京都 港区 芝公園')) }
    end
  end

  describe '.remove_spaces_before_city' do
    subject { described_class.remove_spaces_before_city(input) }

    context '市区より前にスペースがある場合' do
      let(:input) { '東京都 港区 芝' }

      it { is_expected.to(eq('東京都港区 芝')) }
    end

    context '郡町村の場合' do
      let(:input) { '埼玉県 入間郡 三芳町' }

      it { is_expected.to(eq('埼玉県入間郡 三芳町')) }
    end

    context '市区郡がない場合' do
      let(:input) { '東京都 芝公園' }

      it { is_expected.to(eq('東京都 芝公園')) }
    end
  end

  describe '.full_normalize' do
    subject { described_class.full_normalize(input) }

    context '完全な正規化が必要な場合' do
      let(:input) { '　東京都　港区　芝　１－２－３　番地　' }

      it { is_expected.to(eq('東京都港区芝1-2-3番地')) }
    end

    context '漢数字と表記ゆらぎを含む場合' do
      let(:input) { '東京都　千代田区　丸の内　一丁目　二番　' }

      it { is_expected.to(eq('東京都千代田区丸ノ内1丁目 2番')) }
    end

    context '全角英数字を含む場合' do
      let(:input) { '東京都　港区　芝　１丁目　Ａ棟' }

      it { is_expected.to(eq('東京都港区芝1丁目 A棟')) }
    end

    context '実際の住所での正規化' do
      let(:test_cases) do
        [
          ['東京都 港区 芝 １－２－３', '東京都港区芝1-2-3'],
          ['大阪府 大阪市 北区 梅田 ２丁目', '大阪府大阪市北区梅田2丁目'],
          ['京都府 京都市 中京区 三条通', '京都府京都市中京区 3条通'],
          ['神奈川県 横浜市 西区 みなとみらい 三丁目', '神奈川県横浜市西区みなとみらい3丁目'],
          ['愛知県 名古屋市 中区 錦 三丁目 十五番', '愛知県名古屋市中区錦3丁目 15番'],
          ['北海道 札幌市 中央区 南 三条 西 十五丁目', '北海道札幌市中央区南3条 西 15丁目']
        ]
      end

      it '実際の住所を正しく正規化する' do
        test_cases.each do |(input, expected)|
          expect(described_class.full_normalize(input)).to(eq(expected))
        end
      end
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    context 'nilの場合' do
      let(:input) { nil }

      it { is_expected.to(eq('')) }
    end
  end
end
