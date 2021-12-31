# frozen_string_literal: true

RSpec.describe JapaneseAddressParser do
  describe '.call' do
    shared_examples '町丁目まで解析できる' do
      it { is_expected.to be_a(JapaneseAddressParser::Models::Address) }
      it { expect(subject.furigana).to eq(furigana) }
    end

    subject { described_class.call(full_address) }

    context '全角英数字が含まれるとき' do
      let(:full_address) { '東京都港区芝公園４ー２ー８' }
      let(:furigana) { 'トウキョウトミナトクシバコウエン 4' }

      it_behaves_like '町丁目まで解析できる'
    end

    context '英数字+「丁目」という表記のとき' do
      let(:full_address) { '東京都港区芝公園4丁目2-8' }
      let(:furigana) { 'トウキョウトミナトクシバコウエン 4' }

      it_behaves_like '町丁目まで解析できる'
    end
  end
end
