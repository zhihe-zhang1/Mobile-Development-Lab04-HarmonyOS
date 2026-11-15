export const PRODUCT_DETAIL_ROUTE: string = 'ProductDetail';

export interface Product {
  id: string;
  name: string;
  category: string;
  priceCents: number;
  mark: string;
  panelColor: string;
  description: string;
  stock: number;
}

export class DetailRequest {
  id: string;
  isFavorite: boolean;

  constructor(id: string, isFavorite: boolean) {
    this.id = id;
    this.isFavorite = isFavorite;
  }
}

export class DetailResult {
  id: string;
  isFavorite: boolean;

  constructor(id: string, isFavorite: boolean) {
    this.id = id;
    this.isFavorite = isFavorite;
  }
}

const PRODUCTS: Product[] = [
  {
    id: 'EL-101', name: '无线蓝牙耳机', category: '数码', priceCents: 12900,
    mark: '听', panelColor: '#DBE9DB', description: '轻巧的入耳设计，适合通勤、学习和日常听歌。', stock: 18
  },
  {
    id: 'DS-102', name: '方格笔记本', category: '文具', priceCents: 1990,
    mark: '记', panelColor: '#F6E5C9', description: '细方格内页，适合整理课堂笔记与日程。', stock: 42
  },
  {
    id: 'EL-103', name: '折叠桌面支架', category: '数码', priceCents: 3990,
    mark: '立', panelColor: '#DEE7F1', description: '可折叠收纳，桌面查看手机消息或跟练时使用。', stock: 24
  },
  {
    id: 'EL-104', name: '便携蓝牙音箱', category: '数码', priceCents: 15900,
    mark: '响', panelColor: '#E8E0F2', description: '小体积无线音箱，方便在自习室外或露营时携带。', stock: 12
  },
  {
    id: 'LT-105', name: '随行保温杯', category: '日用', priceCents: 6900,
    mark: '饮', panelColor: '#E2ECDE', description: '旋盖式随行杯，满足日常上课和通勤饮水。', stock: 31
  },
  {
    id: 'DS-106', name: '抽绳帆布笔袋', category: '文具', priceCents: 2990,
    mark: '收', panelColor: '#F3E2DC', description: '适合收纳中性笔、橡皮和便携小尺。', stock: 26
  }
];

export function allProducts(): Product[] {
  return PRODUCTS.slice();
}

export function findProductById(id: string): Product | undefined {
  return PRODUCTS.find((item: Product): boolean => item.id === id);
}

export function matchingProducts(products: Product[], keyword: string): Product[] {
  const term: string = keyword.trim().toLowerCase();
  if (term.length === 0) {
    return products;
  }
  return products.filter((product: Product): boolean =>
    product.name.toLowerCase().includes(term) ||
    product.category.toLowerCase().includes(term) ||
    product.id.toLowerCase().includes(term)
  );
}

export function applyFavoriteResult(ids: string[], result: DetailResult): string[] {
  if (findProductById(result.id) === undefined || ids.includes(result.id) === result.isFavorite) {
    return ids;
  }
  return result.isFavorite
    ? ids.concat(result.id)
    : ids.filter((id: string): boolean => id !== result.id);
}

export function describeReturn(name: string, result: DetailResult): string {
  return name + (result.isFavorite ? ' · 已收藏' : ' · 未收藏');
}

export function formatPrice(priceCents: number): string {
  return '¥' + (priceCents / 100).toFixed(2);
}
