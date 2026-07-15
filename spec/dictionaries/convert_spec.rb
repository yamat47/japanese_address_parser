# frozen_string_literal: true

require 'japanese_address_parser/dictionaries/convert'

::RSpec.describe(::JapaneseAddressParser::Dictionaries::Convert) do
  describe '.call' do
    it 'expands an old-form character into a pattern matching both forms' do
      expect(described_class.call('亞')).to(eq('(亞|亜)'))
    end

    it 'expands a new-form character into the same both-forms pattern' do
      expect(described_class.call('亜')).to(eq('(亞|亜)'))
    end

    it 'expands only dictionary characters and leaves the rest untouched' do
      expect(described_class.call('區役所')).to(eq('(區|区)役所'))
    end

    it 'returns a string with no dictionary characters unchanged' do
      expect(described_class.call('東京都')).to(eq('東京都'))
    end

    it 'returns an empty string unchanged' do
      expect(described_class.call('')).to(eq(''))
    end

    # JS の reduce は object キー再代入で「後勝ち」になる。'弁' は 3 つの旧字体
    # (瓣 / 辯 / 辨) の dst なので、patternMap['弁'] は最後に挿入された辨 のパターンになる。
    # この後勝ち挙動を逐語移植できていることを固定する。
    context 'when one new-form character is the destination of several old forms (last-wins)' do
      it 'maps the shared destination to the last entry pattern' do
        expect(described_class.call('弁')).to(eq('(辨|弁)'))
      end

      it 'still maps each old form to its own pattern' do
        expect(described_class.call('瓣')).to(eq('(瓣|弁)'))
        expect(described_class.call('辯')).to(eq('(辯|弁)'))
        expect(described_class.call('辨')).to(eq('(辨|弁)'))
      end
    end
  end
end
