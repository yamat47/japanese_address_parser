# frozen_string_literal: true

require 'japanese_address_parser/normalize_helpers'

::RSpec.describe(::JapaneseAddressParser::NormalizeHelpers) do
  describe '.prenormalize' do
    it 'normalizes a full-width space to a half-width space' do
      expect(described_class.prenormalize('東京都　渋谷区')).to(eq('東京都 渋谷区'))
    end

    it 'collapses consecutive spaces into one' do
      expect(described_class.prenormalize('東京都    渋谷区')).to(eq('東京都 渋谷区'))
    end

    it 'converts full-width alphanumerics to half-width' do
      expect(described_class.prenormalize('Ａｂ１２３')).to(eq('Ab123'))
    end

    context 'with a horizontal bar adjacent to a number' do
      it 'unifies a long-vowel mark to a hyphen' do
        expect(described_class.prenormalize('1ー2')).to(eq('1-2'))
      end

      it 'unifies a full-width minus to a hyphen' do
        expect(described_class.prenormalize('１−２')).to(eq('1-2'))
      end

      it 'unifies an em dash to a hyphen' do
        expect(described_class.prenormalize('五—六')).to(eq('五-六'))
      end
    end

    it 'leaves a horizontal bar that is not adjacent to a number unchanged' do
      expect(described_class.prenormalize('あ—い')).to(eq('あ—い'))
    end

    # 横棒の前側の数字クラスは「百千」を含むが、後ろ側は「十」までで非対称（上流のまま）。
    context 'with the asymmetric digit class around the dash' do
      it 'unifies when 百 precedes the dash (百 is in the leading class)' do
        expect(described_class.prenormalize('百ー')).to(eq('百-'))
      end

      it 'does not unify when 百 follows the dash (百 is absent from the trailing class)' do
        expect(described_class.prenormalize('ー百')).to(eq('ー百'))
      end
    end

    it 'removes spaces before the 丁目 part' do
      expect(described_class.prenormalize('東京都 渋谷区 渋谷 １丁目')).to(eq('東京都渋谷区渋谷1丁目'))
    end

    it 'removes spaces before the 区 within a 市 (政令市)' do
      expect(described_class.prenormalize('京都府 京都 市 北 区')).to(eq('京都府京都市北区'))
    end

    it 'removes spaces before the first number-hyphen run' do
      expect(described_class.prenormalize('東京都 渋谷区 渋谷 1-2-3')).to(eq('東京都渋谷区渋谷1-2-3'))
    end

    it 'normalizes the string to NFC' do
      # 分解形 か(U+304B) + 結合濁点(U+3099) を合成形 が(U+304C) へ正規化する。
      decomposed = [0x304B, 0x3099].pack('U*')
      composed = [0x304C].pack('U*')
      expect(described_class.prenormalize(decomposed)).to(eq(composed))
    end

    it 'applies the whole pipeline to a realistic address' do
      input = '神奈川県　横浜市港北区　大豆戸町　１７番地１１'
      expect(described_class.prenormalize(input)).to(eq('神奈川県横浜市港北区大豆戸町17番地11'))
    end
  end
end
