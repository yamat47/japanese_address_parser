# frozen_string_literal: true

require 'japanese_address_parser/japanese_numeral'

# Cases tagged :upstream_port are ported verbatim from the upstream test suite:
# https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/test/test.ts
# https://github.com/geolonia/japanese-numeral/blob/e09ee1e2d703b66c4c7acae8ad6ced596afe13b7/test/utils.ts
::RSpec.describe(::JapaneseAddressParser::JapaneseNumeral) do
  describe '.kanji2number', :upstream_port do
    it 'parses Japanese numerals as numbers' do
      expect(described_class.kanji2number('〇')).to(eq(0))
      expect(described_class.kanji2number('零')).to(eq(0))
      expect(described_class.kanji2number('一千百十一兆一千百十一億一千百十一万一千百十一')).to(eq(1_111_111_111_111_111))
      expect(described_class.kanji2number('一千百十一兆一千百十一億一千百十一万')).to(eq(1_111_111_111_110_000))
      expect(described_class.kanji2number('一千百十一兆一千百十一億一千百十一')).to(eq(1_111_111_100_001_111))
      expect(described_class.kanji2number('百十一')).to(eq(111))
      expect(described_class.kanji2number('三億八')).to(eq(300_000_008))
      expect(described_class.kanji2number('三百八')).to(eq(308))
      expect(described_class.kanji2number('三五〇')).to(eq(350))
      expect(described_class.kanji2number('三〇八')).to(eq(308))
      expect(described_class.kanji2number('二〇二〇')).to(eq(2020))
      expect(described_class.kanji2number('十')).to(eq(10))
      expect(described_class.kanji2number('二千')).to(eq(2000))
      expect(described_class.kanji2number('壱万')).to(eq(10_000))
      expect(described_class.kanji2number('弍万')).to(eq(20_000))
      expect(described_class.kanji2number('一二三四')).to(eq(1234))
      expect(described_class.kanji2number('千二三四')).to(eq(1234))
      expect(described_class.kanji2number('千二百三四')).to(eq(1234))
      expect(described_class.kanji2number('千二百三十四')).to(eq(1234))
      expect(described_class.kanji2number('壱阡陌拾壱兆壱阡陌拾壱億壱阡陌拾壱萬壱阡陌拾壱')).to(eq(1_111_111_111_111_111))
      expect(described_class.kanji2number('壱仟佰拾壱兆壱仟佰拾壱億壱仟佰拾壱萬壱仟佰拾壱')).to(eq(1_111_111_111_111_111))
    end

    it 'converts mixed Japanese kanji numbers to numbers' do
      expect(described_class.kanji2number('100万')).to(eq(1_000_000))
      expect(described_class.kanji2number('5百')).to(eq(500))
      expect(described_class.kanji2number('7十')).to(eq(70))
      expect(described_class.kanji2number('4千８百')).to(eq(4800))
      expect(described_class.kanji2number('4千８百万')).to(eq(48_000_000))
      expect(described_class.kanji2number('3億4千８百万')).to(eq(348_000_000))
      expect(described_class.kanji2number('3億4千８百万6')).to(eq(348_000_006))
      expect(described_class.kanji2number('2百億')).to(eq(20_000_000_000))
      expect(described_class.kanji2number('4千8百21')).to(eq(4821))
      expect(described_class.kanji2number('1千2百35億8百21')).to(eq(123_500_000_821))
      expect(described_class.kanji2number('2億3千430万')).to(eq(234_300_000))
      expect(described_class.kanji2number('２億３千４５６万７８９０')).to(eq(234_567_890))
      expect(described_class.kanji2number('１２３')).to(eq(123))
    end

    it 'raises TypeError for non-numeral input' do
      expect { described_class.kanji2number('三あ八') }
        .to(raise_error(::TypeError))
      expect { described_class.kanji2number('あ') }
        .to(raise_error(::TypeError))
      expect { described_class.kanji2number('三五十') }
        .to(raise_error(::TypeError))
    end
  end

  describe '.number2kanji', :upstream_port do
    it 'converts numbers to Japanese kanji' do
      expect(described_class.number2kanji(0)).to(eq('〇'))
      expect(described_class.number2kanji(1110)).to(eq('千百十'))
      expect(described_class.number2kanji(1111)).to(eq('千百十一'))
      expect(described_class.number2kanji(1_111_111_111_111_111)).to(eq('千百十一兆千百十一億千百十一万千百十一'))
      expect(described_class.number2kanji(1_111_113_111_111_111)).to(eq('千百十一兆千百三十一億千百十一万千百十一'))
      expect(described_class.number2kanji(1_000_000_000_000_000)).to(eq('千兆'))
      expect(described_class.number2kanji(1_200_000)).to(eq('百二十万'))
      expect(described_class.number2kanji(18)).to(eq('十八'))
      expect(described_class.number2kanji(100_100_000)).to(eq('一億十万'))
    end

    it 'raises TypeError for non-integer input' do
      expect { described_class.number2kanji('hello') }
        .to(raise_error(::TypeError))
    end
  end

  describe '.find_kanji_numbers', :upstream_port do
    it 'finds Japanese kanji numbers' do
      expect(described_class.find_kanji_numbers('今日は二千二十年十一月二十日です。')).to(eq(%w[二千二十 十一 二十]))
      expect(described_class.find_kanji_numbers('今日は二〇二〇年十一月二十日です。')).to(eq(%w[二〇二〇 十一 二十]))
      expect(described_class.find_kanji_numbers('わたしは二千二十億円もっています。')).to(eq(['二千二十億']))
      expect(described_class.find_kanji_numbers('わたしは二〇二〇億円もっています。')).to(eq(['二〇二〇億']))
      expect(described_class.find_kanji_numbers('今日のランチは八百六十三円でした。')).to(eq(['八百六十三']))
      expect(described_class.find_kanji_numbers('今日のランチは八六三円でした。')).to(eq(['八六三']))
      expect(described_class.find_kanji_numbers('今月のお小遣いは三千円です。')).to(eq(['三千']))
      expect(described_class.find_kanji_numbers('青森県五所川原市金木町喜良市千苅６２−８')).to(eq(%w[五 千]))
      expect(described_class.find_kanji_numbers('わたしは1億2000万円もっています。')).to(eq(['1億2000万']))
      expect(described_class.find_kanji_numbers('香川県仲多度郡まんのう町勝浦字家六２０９４番地１')).to(eq(['六']))
    end

    it 'finds mixed Japanese kanji numbers' do
      expect(described_class.find_kanji_numbers('今日は２千20年十一月二十日です。')).to(eq(%w[２千20 十一 二十]))
    end

    it 'finds old Japanese kanji numbers' do
      expect(described_class.find_kanji_numbers('私が住んでいるのは壱番館の弐号室です。')).to(eq(%w[壱 弐]))
      expect(described_class.find_kanji_numbers('私は、ハイツ弍号棟に住んでいます。')).to(eq(['弍']))
      expect(described_class.find_kanji_numbers('私は、壱阡陌拾壱兆壱億壱萬円持っています。')).to(eq(['壱阡陌拾壱兆壱億壱萬']))
      expect(described_class.find_kanji_numbers('私は、壱仟佰拾壱兆壱億壱萬円持っています。')).to(eq(['壱仟佰拾壱兆壱億壱萬']))
    end

    it 'does not find Japanese kanji numbers when only standalone large units are present' do
      expect(described_class.find_kanji_numbers('栗沢町万字寿町')).to(be_empty)
      expect(described_class.find_kanji_numbers('私は億ションに住んでいます')).to(be_empty)
    end
  end

  # Ruby 固有の確認（Onigmo vs V8 差異の初期検出ポイント。working_agreement §3-4）。
  describe 'Ruby-specific behaviour' do
    it 'treats the internal zen2han as digit-only (full-width letters are not converted)' do
      # utils.ts のローカル zen2han は ０-９ のみ対象。英字混じりは別経路（NaN）で TypeError になる。
      expect { described_class.kanji2number('Ａ') }
        .to(raise_error(::TypeError))
    end

    it 'reproduces V8 greedy matching for the empty-capable pattern (not Onigmo first-empty)' do
      # 上流の正規表現は空文字マッチを許す。V8 は "一" を最長マッチで拾うが、素朴な Onigmo
      # マッチは選択肢の先頭（空マッチ）で停止し "一" を取りこぼす。両端アンカー最長マッチで
      # V8 の出力を再現している（working_agreement §3-4 / 設計書 §9.3）。
      expect(described_class.find_kanji_numbers('道玄坂一丁目')).to(eq(['一']))
    end
  end
end
