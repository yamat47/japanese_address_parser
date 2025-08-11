# frozen_string_literal: true

require 'spec_helper'
require 'japanese_address_parser/normalizers/core/inspired/address_postprocessor'

RSpec.describe JapaneseAddressParser::Normalizers::Core::Inspired::AddressPostprocessor do
  describe '.number_to_kanji' do
    it '0を〇に変換する' do
      expect(described_class.number_to_kanji(0)).to eq('〇')
    end

    it '1を一に変換する' do
      expect(described_class.number_to_kanji(1)).to eq('一')
    end

    it '10を十に変換する' do
      expect(described_class.number_to_kanji(10)).to eq('十')
    end

    it '11を十一に変換する' do
      expect(described_class.number_to_kanji(11)).to eq('十一')
    end

    it '20を二十に変換する' do
      expect(described_class.number_to_kanji(20)).to eq('二十')
    end

    it '23を二十三に変換する' do
      expect(described_class.number_to_kanji(23)).to eq('二十三')
    end

    it '100以上は各桁を変換する' do
      expect(described_class.number_to_kanji(123)).to eq('一二三')
    end
  end

  describe '.process' do
    context '町域が特定されている場合' do
      it '先頭のハイフンを削除する' do
        result = described_class.process('-1-2-3', true)
        expect(result).to eq('1-2-3')
      end

      it '数字+丁目を漢数字+丁目に変換する' do
        result = described_class.process('1丁目2番3号', true)
        expect(result).to eq('一丁目2-3')
      end

      it '番地を適切に処理する' do
        result = described_class.process('123番地456号', true)
        expect(result).to eq('123-456')
      end

      it '番地の表記を削除する' do
        result = described_class.process('123番地', true)
        expect(result).to eq('123')
      end

      it '「の」をハイフンに変換する' do
        result = described_class.process('1の2の3', true)
        expect(result).to eq('1-2-3')
      end

      it '漢数字をアラビア数字に変換する' do
        result = described_class.process('一二三番地', true)
        expect(result).to eq('123')
      end

      it '漢数字とハイフンの組み合わせを処理する' do
        result = described_class.process('一－二－三', true)
        expect(result).to eq('1-2-3')
      end

      it '末尾の漢数字を変換する' do
        result = described_class.process('串本町串本一二三四', true)
        expect(result).to eq('串本町串本1234')
      end

      it '複雑な住所表記を正しく処理する' do
        result = described_class.process('一番地二号 建物名', true)
        expect(result).to eq('1-2 建物名')
      end
    end

    context '町域が特定されていない場合' do
      it '住所文字列をそのまま返す' do
        result = described_class.process('1-2-3', false)
        expect(result).to eq('1-2-3')
      end
    end

    context '空文字列やnilの場合' do
      it '空文字列を処理できる' do
        result = described_class.process('', true)
        expect(result).to eq('')
      end

      it 'has_townがfalseの場合は何もしない' do
        result = described_class.process('123番地', false)
        expect(result).to eq('123番地')
      end
    end
  end
end