# frozen_string_literal: true

require 'rspec'
require_relative '../../../lib/japanese_address_parser/normalizers/pipeline'

::RSpec.describe(::JapaneseAddressParser::Normalizers::Pipeline) do
  describe '.normalize' do
    subject { described_class.normalize(input) }

    context '複合的な正規化が必要な場合' do
      let(:input) { '東京都　千代田区　丸の内１－２－３' }

      it '全ての正規化が適用される' do
        expect(subject).to(eq('東京都 千代田区 丸ノ内1-2-3'))
      end
    end

    context '全角英数字と漢数字が混在する場合' do
      let(:input) { 'Ａ区Ｂ町三丁目十五番地' }

      it { is_expected.to(eq('A区B町3丁目15番地')) }
    end

    context '半角カタカナとNFD形式が混在する場合' do
      let(:input) { "ｶﾞｰﾃﾞﾝか\u3099丘" }

      it { is_expected.to(eq('ヶ゛ーテ゛ンヶ丘')) }
    end

    context '表記ゆらぎと漢数字が混在する場合' do
      let(:input) { '三ヶ丘二十三番地' }

      it { is_expected.to(eq('3ヶ丘23番地')) }
    end

    context '複数のハイフン類と数字' do
      let(:input) { '東京都港区芝１ー２－３番地' }

      it { is_expected.to(eq('東京都港区芝1-2-3番地')) }
    end

    context '全角スペースと複数スペース' do
      let(:input) { '東京都　　港区　  芝' }

      it { is_expected.to(eq('東京都 港区 芝')) }
    end

    context '千代田区の例（千を保持）' do
      let(:input) { '東京都千代田区丸の内一丁目' }

      it { is_expected.to(eq('東京都千代田区丸ノ内1丁目')) }
    end

    context '冗長な漢数字表記' do
      let(:input) { '一千二百三十四番地' }

      it { is_expected.to(eq('1234番地')) }
    end

    context '空文字列の場合' do
      let(:input) { '' }

      it { is_expected.to(eq('')) }
    end

    context 'nilの場合' do
      let(:input) { nil }

      it { is_expected.to(eq('')) }
    end

    # 実際の住所での総合テスト
    context '実際の住所での変換' do
      let(:test_cases) do
        [
          ['東京都　港区　芝１－２－３', '東京都 港区 芝1-2-3'],
          ['大阪府大阪市北区梅田２ー３ー４', '大阪府大阪市北区梅田2-3-4'],
          %w[京都府京都市中京区三条通 京都府京都市中京区3条通],
          %w[神奈川県横浜市西区みなとみらい三丁目 神奈川県横浜市西区みなとみらい3丁目],
          %w[愛知県名古屋市中区錦三丁目十五番 愛知県名古屋市中区錦3丁目15番],
          ['福岡県福岡市中央区天神１－１－１', '福岡県福岡市中央区天神1-1-1'],
          %w[北海道札幌市中央区大通西十五丁目 北海道札幌市中央区大通西15丁目],
          %w[宮城県仙台市青葉区一番町四丁目 宮城県仙台市青葉区1番町4丁目]
        ]
      end

      it '実際の住所を正しく変換する' do
        test_cases.each do |(input, expected)|
          expect(described_class.normalize(input)).to(eq(expected))
        end
      end
    end

    # パフォーマンステスト用のデータ
    context '長い文字列の場合' do
      let(:input) { '東京都千代田区丸の内一丁目二番三号東京ビルディング十五階Ａ号室' }

      it '正しく変換される' do
        expect(subject).to(eq('東京都千代田区丸ノ内1丁目2番3号東京ビルディング15階A号室'))
      end
    end
  end

  describe '.normalizers' do
    it 'デフォルトの正規化器リストを返す' do
      expect(described_class.normalizers).to(be_an(Array))
      expect(described_class.normalizers).not_to(be_empty)
    end
  end

  describe '.add_normalizer' do
    let(:custom_normalizer) do
      Module.new do
        def self.normalize(str)
          str&.gsub('test', 'TEST')
        end
      end
    end

    it 'カスタム正規化器を追加できる' do
      pipeline = described_class.dup
      pipeline.add_normalizer(custom_normalizer)
      expect(pipeline.normalize('test string')).to(include('TEST'))
    end
  end
end

