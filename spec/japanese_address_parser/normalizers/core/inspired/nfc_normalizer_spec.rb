# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/nfc_normalizer'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::NfcNormalizer) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context 'NFD形式の文字列' do
      # が = か + ゙
      let(:input) { "か\u3099" }

      it { is_expected.to(eq('が')) }
    end

    context '半角カタカナと濁点の組み合わせ' do
      let(:input) { 'ｶﾞｷﾞｸﾞｹﾞｺﾞ' }

      it { is_expected.to(eq('カ゛キ゛ク゛ケ゛コ゛')) }
    end

    context '半角カタカナと半濁点の組み合わせ' do
      let(:input) { 'ﾊﾟﾋﾟﾌﾟﾍﾟﾎﾟ' }

      it { is_expected.to(eq('ハ゜ヒ゜フ゜ヘ゜ホ゜')) }
    end

    context '結合文字を含む住所' do
      # ペ = ヘ + ゚
      let(:input) { "東京都港区芝ヘ\u309aンション" }

      it { is_expected.to(eq('東京都港区芝ペンション')) }
    end

    context 'すでにNFC形式の文字列' do
      let(:input) { '東京都港区芝' }

      it { is_expected.to(eq('東京都港区芝')) }
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
          %w[東京都港区芝が 東京都港区芝が],
          ['ｶﾞｰﾃﾞﾝｼﾃｨ', 'カ゛ーテ゛ンシティ'],
          ['ﾊﾟｰｸﾏﾝｼｮﾝ', 'ハ゜ークマンション']
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end
  end
end
