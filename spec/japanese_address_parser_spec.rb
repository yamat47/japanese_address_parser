# frozen_string_literal: true

::RSpec.describe(::JapaneseAddressParser) do
  describe '.call' do
    subject { described_class.call(full_address) }

    shared_examples '町丁目まで解析できる' do
      it { is_expected.to(be_a(::JapaneseAddressParser::Models::Address)) }
      it { expect(subject.furigana).to(eq(furigana)) }
    end

    context '全角英数字が含まれるとき' do
      let(:full_address) { '東京都港区芝公園４-２-８'      }
      let(:furigana)     { 'トウキョウトミナトクシバコウエン 4' }

      it_behaves_like '町丁目まで解析できる'
    end

    context '長音が含まれるとき' do
      let(:full_address) { '東京都港区芝公園4ー２ー8'      }
      let(:furigana)     { 'トウキョウトミナトクシバコウエン 4' }

      it_behaves_like '町丁目まで解析できる'
    end

    context '英数字+「丁目」という表記のとき' do
      let(:full_address) { '東京都港区芝公園4丁目2-8' }
      let(:furigana) { 'トウキョウトミナトクシバコウエン 4' }

      it_behaves_like '町丁目まで解析できる'
    end

    context '市の名前が別の都道府県名から始まっているとき' do
      let(:full_address) { '福島県石川郡石川町字長久保185-4' }
      let(:furigana)     { 'フクシマケンイシカワグンイシカワマチ' }

      it_behaves_like '町丁目まで解析できる'
    end
  end
end
