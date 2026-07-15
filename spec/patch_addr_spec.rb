# frozen_string_literal: true

require 'japanese_address_parser/patch_addr'

::RSpec.describe(::JapaneseAddressParser::PatchAddr) do
  describe '.call' do
    # 香川県 仲多度郡まんのう町 勝浦 のパッチ: '\A字?家[6六]' => '家六'
    context 'when pref/city/town match the まんのう町 勝浦 patch' do
      let(:pref) { '香川県'       }
      let(:city) { '仲多度郡まんのう町' }
      let(:town) { '勝浦'        }

      it 'patches the half-width number form' do
        expect(described_class.call(pref, city, town, '家6')).to(eq('家六'))
      end

      it 'patches the kanji number form' do
        expect(described_class.call(pref, city, town, '家六')).to(eq('家六'))
      end

      it 'patches with the optional 字 prefix present' do
        expect(described_class.call(pref, city, town, '字家6')).to(eq('家六'))
      end

      it 'replaces only the matched prefix and keeps the rest' do
        expect(described_class.call(pref, city, town, '家6番地')).to(eq('家六番地'))
      end

      it 'leaves an address that does not match the pattern unchanged' do
        expect(described_class.call(pref, city, town, '山田')).to(eq('山田'))
      end
    end

    it 'applies the あま市 西今宿 patch' do
      expect(described_class.call('愛知県', 'あま市', '西今宿', '梶村1')).to(eq('梶村一'))
    end

    it 'applies the 丸亀市 原田町 patch' do
      expect(described_class.call('香川県', '丸亀市', '原田町', '字東三分一')).to(eq('東三分一'))
    end

    it 'does nothing when the town does not match any patch' do
      expect(described_class.call('香川県', '仲多度郡まんのう町', '別の町', '字家6')).to(eq('字家6'))
    end

    # 始端アンカーの忠実性: JS の `^`（m フラグ無し）は文字列先頭のみにマッチする。
    # Ruby の `^` は行頭にマッチしてしまうため `\A` へ翻訳済み。改行を挟んだ後続行の
    # '家6' は文字列先頭ではないのでマッチしない（`^` 移植だと誤って '家六' に置換される）。
    it 'anchors at the start of the string, not the start of a line (\\A, not ^)' do
      expect(described_class.call('香川県', '仲多度郡まんのう町', '勝浦', "X\n家6")).to(eq("X\n家6"))
    end
  end
end
