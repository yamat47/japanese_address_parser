import oldJapaneseNumerics from './oldJapaneseNumerics'
import japaneseNumerics from './japaneseNumerics'

type NumHash = {
  [key: string]: number;
}

export const largeNumbers: NumHash = { '兆': 1000000000000, '億': 100000000, '万': 10000 }
export const smallNumbers: NumHash = { '千': 1000, '百': 100, '十': 10 }

export function normalize(japanese: string) {
  for (const key in oldJapaneseNumerics) {
    const reg = new RegExp(key, 'g')
    japanese = japanese.replace(reg, oldJapaneseNumerics[key])
  }
  return japanese
}

/**
 * 漢数字を兆、億、万単位に分割する
 */
export function splitLargeNumber(japanese: string) {
  let kanji = japanese
  const numbers:NumHash = {}
  for (const key in largeNumbers) {
    const reg = new RegExp(`(.+)${key}`)
    const match = kanji.match(reg)
    if (match) {
      numbers[key] = kan2n(match[1])
      kanji = kanji.replace(match[0], '')
    } else {
      numbers[key] = 0
    }
  }

  if (kanji) {
    numbers['千'] = kan2n(kanji)
  } else {
    numbers['千'] = 0
  }

  return numbers
}

/**
 * 千単位以下の漢数字を数字に変換する（例: 三千 => 3000）
 *
 * @param japanese
 */
export function kan2n(japanese: string) {
  if (japanese.match(/^[0-9]+$/)) {
    return Number(japanese)
  }

  let kanji = zen2han(japanese)
  let number = 0
  for (const key in smallNumbers) {
    const reg = new RegExp(`(.*)${key}`)
    const match = kanji.match(reg)
    if (match) {
      let n = 1
      if (match[1]) {
        if (match[1].match(/^[0-9]+$/)) {
          n = Number(match[1])
        } else {
          n = japaneseNumerics[match[1]]
        }
      }

      number = number + (n * smallNumbers[key])

      kanji = kanji.replace(match[0], '')
    }
  }

  if (kanji) {
    if (kanji.match(/^[0-9]+$/)) {
      number = number + Number(kanji)
    } else {
      number = number + japaneseNumerics[kanji]
    }
  }

  return number
}

/**
 * Converts number less than 10000 to kanji.
 *
 * @param num
 */
export function n2kan(num: number) {
  const kanjiNumbers = Object.keys(japaneseNumerics)
  let number = num
  let kanji = ''
  for (const key in smallNumbers) {
    const n = Math.floor(number / smallNumbers[key])
    if (n) {
      number = number - (n * smallNumbers[key])
      if (1 === n) {
        kanji = `${kanji}${key}`
      } else {
        kanji = `${kanji}${kanjiNumbers[n]}${key}`
      }
    }
  }

  if (number) {
    kanji = `${kanji}${kanjiNumbers[number]}`
  }

  return kanji
}

/**
 * Converts double-width number to number as string.
 *
 * @param num
 */
export function zen2han(str: string) {
  return str.replace(/[０-９]/g, (s) => {
      return String.fromCharCode(s.charCodeAt(0) - 0xFEE0);
  });
}
