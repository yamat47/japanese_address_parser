# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/hyphen_normalizer'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::HyphenNormalizer) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '数字の後に全角ハイフンがある場合' do
      let(:input) { '1－2－3' }

      it { is_expected.to(eq('1-2-3')) }
    end

    context '数字の前に全角ハイフンがある場合' do
      let(:input) { '東京都港区芝－123' }

      it { is_expected.to(eq('東京都港区芝-123')) }
    end

    context '全角数字と全角ハイフンの組み合わせ' do
      let(:input) { '１－２－３' }

      it { is_expected.to(eq('１-２-３')) }
    end

    context '漢数字と全角ハイフンの組み合わせ' do
      let(:input) { '一－二－三' }

      it { is_expected.to(eq('一-二-三')) }
    end

    context '長音記号（ー）が数字に隣接する場合' do
      let(:input) { '1ー2ー3' }

      it { is_expected.to(eq('1-2-3')) }
    end

    context '半角長音記号（ｰ）が数字に隣接する場合' do
      let(:input) { '1ｰ2ｰ3' }

      it { is_expected.to(eq('1-2-3')) }
    end

    context '様々なダッシュ類が数字に隣接する場合' do
      let(:test_cases) do
        [
          ['1－2', '1-2'],
          ['1−2', '1-2'],
          ['1‐2', '1-2'],
          ['1‑2', '1-2'],
          ['1‒2', '1-2'],
          ['1–2', '1-2'],
          ['1—2', '1-2'],
          ['1―2', '1-2'],
          ['1━2', '1-2'],
          %w[1ー2 1-2],
          %w[1ｰ2 1-2]
        ]
      end

      it 'すべてハイフンに統一される' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    context '数字に隣接しないハイフン類は変換しない' do
      let(:input) { '東京都ー港区' }

      it { is_expected.to(eq('東京都ー港区')) }
    end

    context '数字に隣接しない全角ハイフンは変換しない' do
      let(:input) { '東京都－港区' }

      it { is_expected.to(eq('東京都－港区')) }
    end

    context '複合的なパターン' do
      let(:input) { '東京都港区芝1－2－3番地' }

      it { is_expected.to(eq('東京都港区芝1-2-3番地')) }
    end

    context '〇を含む数字パターン' do
      let(:input) { '二〇二三－一二－三一' }

      it { is_expected.to(eq('二〇二三-一二-三一')) }
    end

    context '十百千を含む数字パターン' do
      let(:input) { '千－百－十' }

      it { is_expected.to(eq('千-百-十')) }
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
          ['東京都港区芝１－２－３', '東京都港区芝１-２-３'],
          ['大阪府大阪市北区梅田2ー3ー4', '大阪府大阪市北区梅田2-3-4'],
          ['神奈川県横浜市西区みなとみらい３−６−１', '神奈川県横浜市西区みなとみらい３-６-１'],
          ['愛知県名古屋市中区錦三丁目十五－一', '愛知県名古屋市中区錦三丁目十五-一'],
          ['福岡県福岡市中央区天神１‐１‐１', '福岡県福岡市中央区天神１-１-１']
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # 境界ケース
    context '文字列の先頭に数字とハイフンがある場合' do
      let(:input) { '－1番地' }

      it { is_expected.to(eq('-1番地')) }
    end

    context '文字列の末尾に数字とハイフンがある場合' do
      let(:input) { '東京都港区芝1－' }

      it { is_expected.to(eq('東京都港区芝1-')) }
    end
  end
end
