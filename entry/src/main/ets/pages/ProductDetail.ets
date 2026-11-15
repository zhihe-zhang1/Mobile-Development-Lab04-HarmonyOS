import { DetailRequest, DetailResult, Product, findProductById, formatPrice } from '../model/Catalog';
import { FOREST, INK, LINE, MUTED, PAPER, PRICE, SAGE, WHITE } from '../model/Palette';

@Builder
export function ProductDetailBuilder() {
  ProductDetail();
}

@Component
struct ProductDetail {
  private pathStack: NavPathStack | undefined = undefined;
  @State private product: Product | undefined = undefined;
  @State private draftFavorite: boolean = false;
  @State private isLeaving: boolean = false;

  private initialize(context: NavDestinationContext): void {
    this.pathStack = context.pathStack;
    this.isLeaving = false;
    const request = context.pathInfo.param as DetailRequest | undefined;
    if (request === undefined || request === null || typeof request.id !== 'string') {
      this.product = undefined;
      this.draftFavorite = false;
      return;
    }
    this.product = findProductById(request.id);
    this.draftFavorite = request.isFavorite === true;
  }

  private saveAndBack(): void {
    const product = this.product;
    const pathStack = this.pathStack;
    if (this.isLeaving || product === undefined || pathStack === undefined) {
      return;
    }
    this.isLeaving = true;
    const result = new DetailResult(product.id, this.draftFavorite);
    pathStack.pop(result);
  }

  private cancelAndBack(): void {
    if (!this.isLeaving) {
      this.isLeaving = true;
      this.pathStack?.pop();
    }
  }

  @Builder
  private specification(label: string, value: string) {
    Row() {
      Text(label).fontSize(14).fontColor(MUTED);
      Text(value).fontSize(14).fontWeight(FontWeight.Medium).fontColor(INK);
    }
    .width('100%')
    .height(41)
    .justifyContent(FlexAlign.SpaceBetween);
  }

  @Builder
  private details(product: Product) {
    Column({ space: 13 }) {
      Column({ space: 9 }) {
        Text('PRODUCT  /  ' + product.id).fontSize(12).letterSpacing(2).fontColor(FOREST);
        Text(product.mark).fontSize(46).fontWeight(FontWeight.Bold).fontColor(FOREST);
        Text(product.name).fontSize(25).fontWeight(FontWeight.Bold).fontColor(INK);
        Text(formatPrice(product.priceCents)).fontSize(19).fontWeight(FontWeight.Bold).fontColor(PRICE);
      }
      .width('100%')
      .padding(18)
      .backgroundColor(product.panelColor)
      .borderRadius(18);

      Column({ space: 3 }) {
        this.specification('商品编号', product.id);
        this.specification('商品分类', product.category);
        this.specification('当前库存', product.stock.toString() + ' 件');
        Divider().color(LINE);
        Text(product.description)
          .fontSize(14).lineHeight(22).fontColor(MUTED).padding({ top: 10, bottom: 5 });
      }
      .alignItems(HorizontalAlign.Start)
      .width('100%')
      .padding({ left: 14, right: 14, top: 5, bottom: 8 })
      .backgroundColor(WHITE)
      .borderRadius(16);

      Row() {
        Column({ space: 4 }) {
          Text('收藏商品').fontSize(16).fontWeight(FontWeight.Bold).fontColor(INK);
          Text('保存返回后，列表会收到收藏状态。').fontSize(12).fontColor(MUTED);
        }
        .layoutWeight(1)
        .alignItems(HorizontalAlign.Start);
        Toggle({ type: ToggleType.Switch, isOn: this.draftFavorite })
          .selectedColor(FOREST)
          .accessibilityText('收藏商品')
          .onChange((isOn: boolean): void => {
            this.draftFavorite = isOn;
          });
      }
      .width('100%')
      .padding(13)
      .backgroundColor(SAGE)
      .borderRadius(15);

      Button('保存并返回')
        .width('100%').height(45).backgroundColor(FOREST)
        .enabled(!this.isLeaving)
        .onClick((): void => {
          this.saveAndBack();
        });

      Button('不保存，直接返回')
        .width('100%').height(42).fontColor(FOREST).backgroundColor(WHITE)
        .enabled(!this.isLeaving)
        .onClick((): void => {
          this.cancelAndBack();
        });
    }
    .width('100%');
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 12 }) {
          if (this.product !== undefined) {
            this.details(this.product);
          } else {
            Text('没有找到对应商品').fontSize(19).fontWeight(FontWeight.Bold).fontColor(INK);
            Button('返回列表').backgroundColor(FOREST)
              .onClick((): void => {
                this.cancelAndBack();
              });
          }
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 12, bottom: 20 });
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Off);
    }
    .title('商品详情')
    .backgroundColor(PAPER)
    .onReady((context: NavDestinationContext): void => {
      this.initialize(context);
    });
  }
}
