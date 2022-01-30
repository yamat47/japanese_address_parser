# @geolonia/japanese-numeral

[![https://github.com/geolonia/wwwdiff/japanese-numeral](https://github.com/geolonia/japanese-numeral/workflows/test/badge.svg)](https://github.com/geolonia/japanese-numeral/actions?query=workflow%3Atest)
[![npm version](https://badge.fury.io/js/%40geolonia%2Fjapanese-numeral.svg)](https://badge.fury.io/js/%40geolonia%2Fjapanese-numeral)

Converts Japanese Kanji numeral <=> number.

## Installation

```bash
$ npm install @geolonia/japanese-numeral --save
```

## Usage

### kanji2number()

Converts Japanese Kanji numeral to number.

```javascript
import { kanji2number } from '@geolonia/japanese-numeral'

console.log(kanji2number('一千百十一兆一千百十一億一千百十一万一千百十一')) // 1111111111111111

// `一千` を `千` と記述しても同じ結果になる。
console.log(kanji2number('千百十一兆千百十一億千百十一万千百十一')) // 1111111111111111

// 漢数字のゼロ `〇` を使用することも可能。
console.log(kanji2number('二〇二〇')) // 2020

// 数字と漢数字が混ざった表記にも対応
console.log(kanji2number('2億3千430万')) // 234300000
console.log(kanji2number('２億３千４５６万７８９０')) // 234567890 （数字は全角でも可）
```

### number2kanji()

Converts number to Japanese Kanji numeral.

```javascript
import { number2kanji } from '@geolonia/japanese-numeral'

console.log(number2kanji(1111111111111111)) // 千百十一兆千百十一億千百十一万千百十一
```

### findKanjiNumbers()

Finds the Japanese numeral numbers as an array.

```javascript
import { findKanjiNumbers } from '@geolonia/japanese-numeral'

console.log(findKanjiNumbers('今日は二千二十年十一月二十日です。')) // [ '二千二十', '十一', '二十' ]
console.log(findKanjiNumbers('今日は二〇二〇年十一月二十日です。')) // [ '二〇二〇', '十一', '二十' ]
console.log(findKanjiNumbers('わたしは二千二十億円もっています。')) // [ '二千二十億' ]
console.log(findKanjiNumbers('わたしは二〇二〇億円もっています。')) // [ '二〇二〇億' ]
console.log(findKanjiNumbers('わたしは1億2000万円もっています。')) // [ '1億2000万' ]
```

## License

[MIT](LICENSE)
