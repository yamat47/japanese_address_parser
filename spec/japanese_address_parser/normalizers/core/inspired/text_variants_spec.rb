# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/text_variants'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::TextVariants) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context 'ヶケがの統一' do
      let(:input) { '霞ケ関一ツ橋' }

      it { is_expected.to(eq('霞ヶ関一ツ橋')) }
    end

    context 'ヵカか力の統一' do
      let(:input) { '一ヵ月カ所' }

      it { is_expected.to(eq('一ヶ月ヶ所')) }
    end

    context '之ノのの統一' do
      let(:input) { '木之本町木の本' }

      it { is_expected.to(eq('木ノ本町木ノ本')) }
    end

    context 'ッツっつの統一' do
      let(:input) { '三ッ谷町三つ谷' }

      it { is_expected.to(eq('三ツ谷町三ツ谷')) }
    end

    context 'ニ二の統一' do
      let(:input) { '二本松ニ番町' }

      it { is_expected.to(eq('二本松二番町')) }
    end

    context 'ハ八の統一' do
      let(:input) { '八幡町ハ番地' }

      it { is_expected.to(eq('八幡町八番地')) }
    end

    context '埠頭/ふ頭の統一' do
      let(:input) { '横浜ふ頭' }

      it { is_expected.to(eq('横浜埠頭')) }
    end

    context '番町/番丁の統一' do
      let(:input) { '一番丁' }

      it { is_expected.to(eq('一番町')) }
    end

    context '通り/とおりの統一' do
      let(:input) { '四条とおり' }

      it { is_expected.to(eq('四条通り')) }
    end

    context '塚/塚の統一（異体字）' do
      # U+FA10 (CJK互換漢字) → U+585A (通常の塚)
      let(:input) { '塚本町' }

      it { is_expected.to(eq('塚本町')) }
    end

    context '釜/竈の統一' do
      let(:input) { '竈門神社前' }

      it { is_expected.to(eq('釜門神社前')) }
    end

    context '條/条の統一' do
      let(:input) { '四條通' }

      it { is_expected.to(eq('四条通')) }
    end

    context '複数の表記ゆらぎが混在する場合' do
      let(:input) { '霞ケ関三ッ谷ふ頭二番丁' }

      it { is_expected.to(eq('霞ヶ関三ツ谷埠頭二番町')) }
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
          %w[東京都千代田区霞ケ関 東京都千代田区霞ヶ関],
          %w[茨城県つくば市 茨城県ツくば市],
          %w[岐阜県各務原市那加桜町 岐阜県各務原市那加桜町],
          %w[愛知県名古屋市中区錦三丁目 愛知県名古屋市中区錦三丁目],
          %w[福岡県福岡市博多区博多ふ頭 福岡県福岡市博多区博多埠頭]
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # JavaScript実装との互換性確認用
    context 'JS実装の表記ゆらぎパターンと同じ変換を行う' do
      # @geolonia/normalize-japanese-addresses v2.10.0
      # src/lib/dict.ts の toRegexPattern に準拠
      let(:test_cases) do
        [
          %w[三栄町 三栄町],
          %w[くじ野川 くじ野川],
          %w[柿さき町 柿さき町],
          %w[大宜 大宜],
          %w[えぶり えぶり],
          %w[薮田 薮田],
          %w[淵上 渕上],
          %w[曽根 曽根],
          %w[船橋 舟橋]
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
