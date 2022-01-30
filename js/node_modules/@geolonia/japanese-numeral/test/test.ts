import { kanji2number, number2kanji, findKanjiNumbers } from '../src'
import { assert } from 'chai'

describe('Tests for japaneseNumeral.', () => {
  it('Japanese numeric should be parsed as numbers.', () => {
    assert.deepEqual(kanji2number('一千百十一兆一千百十一億一千百十一万一千百十一'), 1111111111111111)
    assert.deepEqual(kanji2number('一千百十一兆一千百十一億一千百十一万'), 1111111111110000)
    assert.deepEqual(kanji2number('一千百十一兆一千百十一億一千百十一'), 1111111100001111)
    assert.deepEqual(kanji2number('百十一'), 111)
    assert.deepEqual(kanji2number('三億八'), 300000008)
    assert.deepEqual(kanji2number('三百八'), 308)
    assert.deepEqual(kanji2number('三〇八'), 308)
    assert.deepEqual(kanji2number('二〇二〇'), 2020)
    assert.deepEqual(kanji2number('二千'), 2000)
    assert.deepEqual(kanji2number('壱万'), 10000)
    assert.deepEqual(kanji2number('一二三四'), 1234)
    assert.deepEqual(kanji2number('壱阡陌拾壱兆壱阡陌拾壱億壱阡陌拾壱萬壱阡陌拾壱'), 1111111111111111)
    assert.deepEqual(kanji2number('壱仟佰拾壱兆壱仟佰拾壱億壱仟佰拾壱萬壱仟佰拾壱'), 1111111111111111)
  });

  it('Number should be converted to Japanese kanji', () => {
    assert.deepEqual(number2kanji(1111111111111111), '千百十一兆千百十一億千百十一万千百十一')
    assert.deepEqual(number2kanji(1111113111111111), '千百十一兆千百三十一億千百十一万千百十一')
    assert.deepEqual(number2kanji(1000000000000000), '千兆')
    assert.deepEqual(number2kanji(1200000), '百二十万')
    assert.deepEqual(number2kanji(18), '十八')
    assert.deepEqual(number2kanji(100100000), '一億十万')
  });

  it('should returns the instance of TypeError', () => {
    // @ts-ignore
    assert.throws(() => number2kanji('hello'), TypeError)

    // @ts-ignore
    assert.throws(() => kanji2number('三あ八'), TypeError)

    // @ts-ignore
    assert.throws(() => kanji2number('あ'), TypeError)
  });

  it('should find Japanese Kanji numbers.', () => {
    assert.deepEqual([ '二千二十', '十一', '二十' ], findKanjiNumbers('今日は二千二十年十一月二十日です。'))
    assert.deepEqual([ '二〇二〇', '十一', '二十' ], findKanjiNumbers('今日は二〇二〇年十一月二十日です。'))
    assert.deepEqual([ '二千二十億' ], findKanjiNumbers('わたしは二千二十億円もっています。'))
    assert.deepEqual([ '二〇二〇億' ], findKanjiNumbers('わたしは二〇二〇億円もっています。'))
    assert.deepEqual([ '八百六十三' ], findKanjiNumbers('今日のランチは八百六十三円でした。'))
    assert.deepEqual([ '八六三' ], findKanjiNumbers('今日のランチは八六三円でした。'))
    assert.deepEqual([ '三千' ], findKanjiNumbers('今月のお小遣いは三千円です。'))
    assert.deepEqual([ '五', '千' ], findKanjiNumbers('青森県五所川原市金木町喜良市千苅６２−８'))
    assert.deepEqual([ '1億2000万' ], findKanjiNumbers('わたしは1億2000万円もっています。'))
    assert.deepEqual([ '六' ], findKanjiNumbers('香川県仲多度郡まんのう町勝浦字家六２０９４番地１'))
  })

  it('should not find Japanese Kanji numbers.', () => {
    assert.deepEqual(0, findKanjiNumbers('栗沢町万字寿町').length)
    assert.deepEqual(0, findKanjiNumbers('私は億ションに住んでいます').length)
  })

  it('should find mixed Japanese Kanji numbers.', () => {
    assert.deepEqual([ '２千20', '十一', '二十' ], findKanjiNumbers('今日は２千20年十一月二十日です。'))
  })

  it('should find old Japanese Kanji numbers.', () => {
    assert.deepEqual([ '壱', '弐' ], findKanjiNumbers('私が住んでいるのは壱番館の弐号室です。'))
    assert.deepEqual([ '壱阡陌拾壱兆壱億壱萬', ], findKanjiNumbers('私は、壱阡陌拾壱兆壱億壱萬円持っています。'))
    assert.deepEqual([ '壱仟佰拾壱兆壱億壱萬', ], findKanjiNumbers('私は、壱仟佰拾壱兆壱億壱萬円持っています。'))
  })

  it('should convert mixed Japanese Kanji numbers to numbers.', () => {
    assert.deepEqual(kanji2number('100万'), 1000000)
    assert.deepEqual(kanji2number('5百'), 500)
    assert.deepEqual(kanji2number('7十'), 70)
    assert.deepEqual(kanji2number('4千８百'), 4800)
    assert.deepEqual(kanji2number('4千８百万'), 48000000)
    assert.deepEqual(kanji2number('3億4千８百万'), 348000000)
    assert.deepEqual(kanji2number('3億4千８百万6'), 348000006)
    assert.deepEqual(kanji2number('2百億'), 20000000000)
  })

  it('`4千8百21` should be converted to `4821`', () => {
    assert.deepEqual(kanji2number('4千8百21'), 4821)
  })

  it('`1千2百億8百21` should be converted to `120000000821`', () => {
    assert.deepEqual(kanji2number('1千2百35億8百21'), 123500000821)
  })

  it('`2億3千430万` should be converted to `234300000`', () => {
    assert.deepEqual(kanji2number('2億3千430万'), 234300000)
  })

  it('`２億３千４５６万７８９０` should be converted to `234567890`', () => {
    assert.deepEqual(kanji2number('２億３千４５６万７８９０'), 234567890)
  })

  it('`１２３` should be converted to `123`', () => {
    assert.deepEqual(kanji2number('１２３'), 123)
  })
});

// https://github.com/geolonia/normalize-japanese-addresses/issues/94
it('should find Japanese Kanji number `六` in `香川県仲多度郡まんのう町勝浦字家六２０９４番地１`.', () => {
  assert.deepEqual([ '六' ], findKanjiNumbers('香川県仲多度郡まんのう町勝浦字家六２０９４番地１'))
})

it('should find Japanese Kanji number in `今日は２千20年十一月二十日です。`.', () => {
  assert.deepEqual([ '２千20', '十一', '二十' ], findKanjiNumbers('今日は２千20年十一月二十日です。'))
})
