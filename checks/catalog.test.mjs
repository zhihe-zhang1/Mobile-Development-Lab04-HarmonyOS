import assert from 'node:assert/strict'
import test from 'node:test'
import {
  DetailRequest, DetailResult, allProducts, applyFavoriteResult, describeReturn,
  findProductById, formatPrice, matchingProducts
} from './Catalog.mts'

test('all fixture products have unique stable IDs and complete detail fields', () => {
  const products = allProducts()
  assert.equal(products.length, 6)
  assert.equal(new Set(products.map(item => item.id)).size, products.length)
  assert.ok(products.every(item => item.id && item.name && item.description && item.priceCents > 0))
  assert.equal(findProductById('EL-104')?.name, '便携蓝牙音箱')
  assert.equal(findProductById('invalid'), undefined)
})

test('search matches names, categories or ids, with trimmed case-insensitive terms', () => {
  const products = allProducts()
  assert.deepEqual(matchingProducts(products, '蓝牙').map(p => p.id), ['EL-101', 'EL-104'])
  assert.deepEqual(matchingProducts(products, '  el-104 ').map(p => p.id), ['EL-104'])
  assert.equal(matchingProducts(products, '数码').length, 3)
  assert.deepEqual(matchingProducts(products, '  '), products)
  assert.deepEqual(matchingProducts(products, '不存在'), [])
})

test('a typed result changes only the matching saved item and does not mutate prior state', () => {
  const request = new DetailRequest('EL-101', false)
  const original = ['DS-102']
  const next = applyFavoriteResult(original, new DetailResult(request.id, true))
  assert.deepEqual(next, ['DS-102', 'EL-101'])
  assert.deepEqual(original, ['DS-102'])
  assert.deepEqual(applyFavoriteResult(next, new DetailResult(request.id, true)), next)
  assert.deepEqual(applyFavoriteResult(next, new DetailResult(request.id, false)), original)
  assert.deepEqual(applyFavoriteResult(next, new DetailResult('invalid', true)), next)
  assert.equal(describeReturn('耳机', new DetailResult(request.id, true)), '耳机 · 已收藏')
  assert.equal(describeReturn('耳机', new DetailResult(request.id, false)), '耳机 · 未收藏')
})

test('price cents render as RMB with a stable two-decimal precision', () => {
  assert.equal(formatPrice(12900), '¥129.00')
  assert.equal(formatPrice(3990), '¥39.90')
})
