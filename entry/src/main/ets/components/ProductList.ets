import { Product, formatPrice } from '../model/Catalog';
import { FOREST, INK, LINE, MUTED, PRICE, WHITE } from '../model/Palette';

@Component
export struct ProductList {
  @Prop products: Product[] = [];
  @Prop favoriteIds: string[] = [];
  onProductClick: (product: Product) => void = (_product: Product): void => {};

  build() {
    Column({ space: 9 }) {
      if (this.products.length === 0) {
        Column({ space: 6 }) {
          Text('没有匹配的商品').fontSize(17).fontWeight(FontWeight.Bold).fontColor(INK);
          Text('试试商品名称、分类或编号').fontSize(13).fontColor(MUTED);
        }
        .width('100%')
        .padding(20)
        .backgroundColor(WHITE)
        .borderRadius(16);
      } else {
        ForEach(this.products, (product: Product) => {
          Row({ space: 12 }) {
            Text(product.mark)
              .fontSize(21)
              .fontWeight(FontWeight.Bold)
              .fontColor(FOREST)
              .textAlign(TextAlign.Center)
              .width(44)
              .height(44)
              .borderRadius(12)
              .backgroundColor(product.panelColor);
            Column({ space: 4 }) {
              Text(product.name).fontSize(16).fontWeight(FontWeight.Bold).fontColor(INK);
              Text(product.category + '  /  ' + product.id).fontSize(12).fontColor(MUTED);
            }
            .layoutWeight(1)
            .alignItems(HorizontalAlign.Start);
            Column({ space: 4 }) {
              Text(formatPrice(product.priceCents)).fontSize(14).fontWeight(FontWeight.Medium).fontColor(PRICE);
              if (this.favoriteIds.includes(product.id)) {
                Text('已收藏').fontSize(11).fontColor(FOREST);
              }
            }
            .alignItems(HorizontalAlign.End);
            Text('›').fontSize(22).fontColor(MUTED);
          }
          .width('100%')
          .constraintSize({ minHeight: 69 })
          .padding({ left: 12, right: 12, top: 9, bottom: 9 })
          .backgroundColor(WHITE)
          .border({ width: 1, color: LINE, radius: 15 })
          .accessibilityText('查看' + product.name + '详情')
          .onClick(() => {
            this.onProductClick(product);
          });
        }, (product: Product): string => product.id);
      }
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start);
  }
}
