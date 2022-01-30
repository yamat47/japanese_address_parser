import { n2kan, kan2n } from '../src/utils'
import { assert } from 'chai'

describe('Tests for utils.', () => {
  it('Small Japanese numeric should be parsed as numbers.', () => {
    assert.deepEqual(n2kan(1111), '千百十一')
    assert.deepEqual(n2kan(3111), '三千百十一')
    assert.deepEqual(n2kan(1000), '千')
    assert.deepEqual(n2kan(5), '五')
  });

  it('`kan2n()` should returns value as expected.', () => {
    assert.deepEqual(kan2n('三千'), 3000)
    assert.deepEqual(kan2n('22'), 22)
    assert.deepEqual(kan2n('１２３'), 123)
  })
});
