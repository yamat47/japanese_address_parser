# frozen_string_literal: true

require 'japanese_address_parser/kan2num'

::RSpec.describe(::JapaneseAddressParser::Kan2num) do
  describe '.call' do
    it 'converts a single kanji numeral to an arabic numeral' do
      expect(described_class.call('三丁目')).to(eq('3丁目'))
    end

    it 'converts multiple kanji numerals in one string' do
      expect(described_class.call('一丁目十一番')).to(eq('1丁目11番'))
    end

    # JS の String.prototype.replace(searchString, ...) は最初の 1 件のみ置換する。
    # gsub で実装すると先に '一' を全置換してしまい '十一' が壊れる（'1丁目十1番'）。
    # sub での移植が正しいことを固定するケース。
    it 'replaces only the first occurrence per found numeral (sub, not gsub)' do
      expect(described_class.call('一丁目十一番')).to(eq('1丁目11番'))
      expect(described_class.call('一丁目十一番')).not_to(eq('1丁目十1番'))
    end

    it 'leaves a string without kanji numerals unchanged' do
      expect(described_class.call('東京都')).to(eq('東京都'))
    end

    it 'leaves full-width alphabets (non kanji numerals) unchanged' do
      expect(described_class.call('ＡＢＣ')).to(eq('ＡＢＣ'))
    end

    # 上流挙動の忠実移植: kan2num は文脈を見ないため '千代田' の '千' も数値化する。
    # 「改善しない」(working_agreement §3-2) を固定するケース。
    it 'faithfully converts kanji numerals even inside place names (upstream behaviour)' do
      expect(described_class.call('千代田区')).to(eq('1000代田区'))
    end

    # JS の try/catch に対応する rescue の検証。
    # kanji2number('万一') は TypeError を投げるので、そのトークンは置換されず元のまま残る。
    it 'ignores tokens that raise in kanji2number and keeps them as-is' do
      expect(described_class.call('万一')).to(eq('万一'))
    end

    it 'keeps processing remaining tokens after a raising token is ignored' do
      expect(described_class.call('万一の三丁目')).to(eq('万一の3丁目'))
    end
  end
end
