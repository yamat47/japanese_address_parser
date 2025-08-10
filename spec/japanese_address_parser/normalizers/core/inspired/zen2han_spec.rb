# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/zen2han'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::Zen2han) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '全角英字を含む場合' do
      let(:input) { 'ＡＢＣ' }

      it { is_expected.to(eq('ABC')) }
    end

    context '全角小文字英字を含む場合' do
      let(:input) { 'ａｂｃ' }

      it { is_expected.to(eq('abc')) }
    end

    context '全角数字を含む場合' do
      let(:input) { '１２３' }

      it { is_expected.to(eq('123')) }
    end

    context '全角英数字混在の場合' do
      let(:input) { 'Ａ１Ｂ２Ｃ３' }

      it { is_expected.to(eq('A1B2C3')) }
    end

    context '全角英数字と日本語が混在する場合' do
      let(:input) { '東京都港区１－２－３' }

      # 注: JavaScript実装では全角ハイフン（－）は変換されない
      it { is_expected.to(eq('東京都港区1－2－3')) }
    end

    context '半角英数字はそのまま' do
      let(:input) { 'ABC123' }

      it { is_expected.to(eq('ABC123')) }
    end

    context '日本語はそのまま' do
      let(:input) { '東京都港区芝公園' }

      it { is_expected.to(eq('東京都港区芝公園')) }
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    # JavaScript実装との互換性確認用
    context 'JS実装と同じ結果を返す' do
      # @geolonia/normalize-japanese-addresses v2.10.0
      # src/lib/zen2han.ts の実装に準拠
      let(:test_cases) do
        [
          %w[ＡＢＣＤＥＦＧＨＩＪＫＬＭＮＯＰＱＲＳＴＵＶＷＸＹＺ ABCDEFGHIJKLMNOPQRSTUVWXYZ],
          %w[ａｂｃｄｅｆｇｈｉｊｋｌｍｎｏｐｑｒｓｔｕｖｗｘｙｚ abcdefghijklmnopqrstuvwxyz],
          %w[０１２３４５６７８９ 0123456789]
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
