# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/kan2num'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::Kan2num) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '基本的な漢数字' do
      let(:input) { '一二三' }

      it { is_expected.to(eq('123')) }
    end

    context '丁目表記' do
      let(:input) { '三丁目' }

      it { is_expected.to(eq('3丁目')) }
    end

    context '番地表記' do
      let(:input) { '十五番地' }

      it { is_expected.to(eq('15番地')) }
    end

    context '一桁の漢数字' do
      let(:input) { '東京都港区芝一' }

      it { is_expected.to(eq('東京都港区芝1')) }
    end

    context '二桁の漢数字（十を含む）' do
      let(:input) { '十二番' }

      it { is_expected.to(eq('12番')) }
    end

    context '二桁の漢数字（二十以上）' do
      let(:input) { '二十三番地' }

      it { is_expected.to(eq('23番地')) }
    end

    context '三桁の漢数字' do
      let(:input) { '百二十三番地' }

      it { is_expected.to(eq('123番地')) }
    end

    context '千を含む漢数字' do
      let(:input) { '千二百三十四番地' }

      it { is_expected.to(eq('1234番地')) }
    end

    context '〇を含む漢数字' do
      let(:input) { '二〇二三年' }

      it { is_expected.to(eq('2023年')) }
    end

    context '漢数字が複数箇所にある場合' do
      let(:input) { '一丁目二番地三号' }

      it { is_expected.to(eq('1丁目2番地3号')) }
    end

    context '漢数字がない場合' do
      let(:input) { '東京都港区芝公園' }

      it { is_expected.to(eq('東京都港区芝公園')) }
    end

    context '既にアラビア数字の場合' do
      let(:input) { '東京都港区芝3-1-1' }

      it { is_expected.to(eq('東京都港区芝3-1-1')) }
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    context 'nilの場合' do
      let(:input) { nil }

      it { is_expected.to(eq('')) }
    end

    # 実際の住所でのテスト
    context '実際の住所での変換' do
      let(:test_cases) do
        [
          %w[東京都千代田区丸の内一丁目 東京都千代田区丸の内1丁目],
          %w[京都府京都市中京区三条通 京都府京都市中京区3条通],
          %w[大阪府大阪市北区梅田二丁目 大阪府大阪市北区梅田2丁目],
          %w[神奈川県横浜市西区みなとみらい三丁目 神奈川県横浜市西区みなとみらい3丁目],
          %w[愛知県名古屋市中区錦三丁目十五番 愛知県名古屋市中区錦3丁目15番]
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # 特殊なケース
    context '特殊な漢数字表記' do
      let(:test_cases) do
        [
          %w[十 10],
          %w[百 100],
          %w[千 1000],
          %w[一十 10],
          %w[一百 100],
          %w[一千 1000]
        ]
      end

      it 'すべてのテストケースで期待する結果を返す' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end
  end
end
