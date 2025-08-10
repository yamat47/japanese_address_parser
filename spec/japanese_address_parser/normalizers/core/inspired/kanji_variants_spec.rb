# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/kanji_variants'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::KanjiVariants) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '旧字体を含む場合' do
      let(:input) { '亞細亞' }

      it { is_expected.to(eq('亜細亜')) }
    end

    context '旧字体の地名' do
      let(:input) { '東京都澁谷區' }

      it { is_expected.to(eq('東京都渋谷区')) }
    end

    context '旧字体と新字体が混在する場合' do
      let(:input) { '神奈川縣横濱市' }

      it { is_expected.to(eq('神奈川県横浜市')) }
    end

    context '新字体はそのまま' do
      let(:input) { '東京都渋谷区' }

      it { is_expected.to(eq('東京都渋谷区')) }
    end

    context '変換対象外の文字はそのまま' do
      let(:input) { '東京都港区芝公園' }

      it { is_expected.to(eq('東京都港区芝公園')) }
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    context 'nilの場合' do
      let(:input) { nil }

      it { is_expected.to(eq('')) }
    end

    # JavaScript実装との互換性確認用
    context 'JS実装の辞書データと同じ変換を行う' do
      # @geolonia/normalize-japanese-addresses v2.10.0
      # src/lib/dict.ts の JIS_OLD_KANJI と JIS_NEW_KANJI に準拠
      let(:test_cases) do
        [
          %w[亞圍壹榮驛 亜囲壱栄駅],
          %w[應櫻假會懷 応桜仮会懐],
          %w[覺樂陷歡氣 覚楽陥歓気],
          %w[縣廳區學校 県庁区学校],
          %w[澁谷驛前廣場 渋谷駅前広場],
          %w[舊市街區畫 旧市街区画],
          %w[醫學專門學校 医学専門学校],
          %w[國會議事堂 国会議事堂],
          %w[縣營體育館 県営体育館],
          %w[廣島縣廣島市 広島県広島市]
        ]
      end

      it 'すべてのテストケースで期待する結果を返す' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # 実際の住所でのテスト
    context '実際の住所での変換' do
      let(:test_cases) do
        [
          %w[靜岡縣濱松市 静岡県浜松市],
          %w[新潟縣佐渡市 新潟県佐渡市],
          %w[廣島縣廣島市 広島県広島市],
          %w[兵庫縣神戸市 兵庫県神戸市],
          %w[福岡縣福岡市 福岡県福岡市]
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
