# frozen_string_literal: true

# spec_helperはSchmooze依存があるため、最小限の設定で実行
require 'rspec'
require_relative '../../../../../lib/japanese_address_parser/normalizers/core/inspired/space_normalizer'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Core::Inspired::SpaceNormalizer) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '全角スペースを含む場合' do
      let(:input) { '東京都　港区　芝' }

      it { is_expected.to(eq('東京都 港区 芝')) }
    end

    context '複数の半角スペースを含む場合' do
      let(:input) { '東京都  港区   芝' }

      it { is_expected.to(eq('東京都 港区 芝')) }
    end

    context '全角スペースと半角スペースが混在する場合' do
      let(:input) { '東京都　 港区  　芝' }

      it { is_expected.to(eq('東京都 港区 芝')) }
    end

    context '文字列の先頭と末尾にスペースがある場合' do
      let(:input) { '　東京都港区芝　' }

      it { is_expected.to(eq(' 東京都港区芝 ')) }
    end

    context '連続する全角スペース' do
      let(:input) { '東京都　　　港区' }

      it { is_expected.to(eq('東京都 港区')) }
    end

    context 'スペースが含まれない場合' do
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

    context 'スペースのみの場合' do
      let(:input) { '　　  　' }

      it { is_expected.to(eq(' ')) }
    end

    # 実際の住所でのテスト
    context '実際の住所での変換' do
      let(:test_cases) do
        [
          ['東京都　港区　芝１－２－３', '東京都 港区 芝１－２－３'],
          ['大阪府  大阪市  北区', '大阪府 大阪市 北区'],
          ['神奈川県　　横浜市　　西区', '神奈川県 横浜市 西区'],
          ['愛知県　 名古屋市  　中区', '愛知県 名古屋市 中区']
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # タブ文字などの他の空白文字は変換しないことを確認
    context 'タブ文字は変換しない' do
      let(:input) { "東京都\t港区" }

      it { is_expected.to(eq("東京都\t港区")) }
    end

    context '改行文字は変換しない' do
      let(:input) { "東京都\n港区" }

      it { is_expected.to(eq("東京都\n港区")) }
    end
  end
end
