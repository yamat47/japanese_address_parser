# frozen_string_literal: true

require 'spec_helper'
require 'japanese_address_parser/normalizers/core/inspired/patch_addr'

RSpec.describe JapaneseAddressParser::Normalizers::Core::Inspired::PatchAddr do
  describe '.patch_addr' do
    context '香川県仲多度郡まんのう町勝浦の場合' do
      it '家6を家六に変換する' do
        result = described_class.patch_addr('香川県', '仲多度郡まんのう町', '勝浦', '家6番地')
        expect(result).to eq('家六番地')
      end

      it '字家六を家六に変換する' do
        result = described_class.patch_addr('香川県', '仲多度郡まんのう町', '勝浦', '字家六番地')
        expect(result).to eq('家六番地')
      end
    end

    context '愛知県あま市西今宿の場合' do
      it '梶村1を梶村一に変換する' do
        result = described_class.patch_addr('愛知県', 'あま市', '西今宿', '梶村1番地')
        expect(result).to eq('梶村一番地')
      end

      it '字梶村一を梶村一に変換する' do
        result = described_class.patch_addr('愛知県', 'あま市', '西今宿', '字梶村一番地')
        expect(result).to eq('梶村一番地')
      end
    end

    context '香川県丸亀市原田町の場合' do
      it '東三分1を東三分一に変換する' do
        result = described_class.patch_addr('香川県', '丸亀市', '原田町', '東三分1番地')
        expect(result).to eq('東三分一番地')
      end

      it '字東三分一を東三分一に変換する' do
        result = described_class.patch_addr('香川県', '丸亀市', '原田町', '字東三分一番地')
        expect(result).to eq('東三分一番地')
      end
    end

    context 'パッチが適用されない場合' do
      it '東京都の住所はそのまま返す' do
        result = described_class.patch_addr('東京都', '渋谷区', '恵比寿', '1-1-1')
        expect(result).to eq('1-1-1')
      end

      it '該当しない市町村の場合はそのまま返す' do
        result = described_class.patch_addr('香川県', '高松市', '番町', '1-1-1')
        expect(result).to eq('1-1-1')
      end
    end

    context '空文字列やnilの場合' do
      it '空文字列を処理できる' do
        result = described_class.patch_addr('東京都', '渋谷区', '恵比寿', '')
        expect(result).to eq('')
      end
    end
  end
end