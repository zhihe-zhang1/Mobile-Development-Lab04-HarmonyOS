import { ProductList } from '../components/ProductList';
import {
  Product, DetailRequest, DetailResult, PRODUCT_DETAIL_ROUTE,
  allProducts, applyFavoriteResult, describeReturn, matchingProducts
} from '../model/Catalog';
import { FOREST, INK, LINE, MUTED, PAPER, SAGE, WHITE } from '../model/Palette';

@Entry
@Component
struct Index {
  private readonly pathStack: NavPathStack = new NavPathStack();
  private readonly tabController: TabsController = new TabsController();
  private readonly products: Product[] = allProducts();

  @State private selectedTab: number = 0;
  @State private keyword: string = '';
  @State private favoriteIds: string[] = [];
  @State private latestReturn: string = '';

  private openDetail(product: Product): void {
    const request = new DetailRequest(product.id, this.favoriteIds.includes(product.id));
    this.pathStack.pushPathByName(PRODUCT_DETAIL_ROUTE, request, (info: PopInfo): void => {
      const result = info.result as DetailResult | undefined;
      if (result === undefined || result === null || result.id !== product.id ||
        typeof result.isFavorite !== 'boolean') {
        return;
      }
      this.favoriteIds = applyFavoriteResult(this.favoriteIds, result);
      this.latestReturn = describeReturn(product.name, result);
    });
  }

  private displayedProducts(): Product[] {
    return matchingProducts(this.products, this.keyword);
  }

  private savedProducts(): Product[] {
    return this.products.filter((product: Product): boolean => this.favoriteIds.includes(product.id));
  }

  @Builder
  private hero(kicker: string, title: string, subtitle: string) {
    Column({ space: 7 }) {
      Text(kicker).fontSize(11).letterSpacing(2).fontWeight(FontWeight.Bold).fontColor('#C0DEC8');
      Text(title).fontSize(30).fontWeight(FontWeight.Bold).fontColor(WHITE);
      Text(subtitle).fontSize(13).fontColor('#E1EDE3');
    }
    .alignItems(HorizontalAlign.Start)
    .width('100%')
    .padding({ left: 18, right: 18, top: 15, bottom: 16 })
    .backgroundColor(FOREST)
    .borderRadius(18);
  }

  @Builder
  private catalogTab() {
    Scroll() {
      Column({ space: 10 }) {
        this.hero('LAB 04   /   ROUTE SHOP', '路由小铺', '点击商品查看详情，保存后回到列表');

        TextInput({ text: this.keyword, placeholder: '搜索商品名称、分类或编号' })
          .width('100%')
          .height(44)
          .fontSize(14)
          .fontColor(INK)
          .backgroundColor(WHITE)
          .onChange((value: string): void => {
            this.keyword = value;
          });

        if (this.latestReturn.length > 0) {
          Column({ space: 3 }) {
            Text('已收到详情页返回结果').fontSize(11).fontWeight(FontWeight.Bold).fontColor(FOREST);
            Text(this.latestReturn).fontSize(14).fontColor(INK);
          }
          .alignItems(HorizontalAlign.Start)
          .width('100%')
          .padding({ left: 13, right: 13, top: 8, bottom: 8 })
          .backgroundColor(SAGE)
          .borderRadius(12);
        }

        Row() {
          Text('全部商品').fontSize(18).fontWeight(FontWeight.Bold).fontColor(INK);
          Text(this.displayedProducts().length.toString() + ' 件')
            .fontSize(12).fontColor(FOREST).padding({ left: 10, right: 10, top: 4, bottom: 4 })
            .backgroundColor(SAGE).borderRadius(12);
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween);

        ProductList({
          products: this.displayedProducts(),
          favoriteIds: this.favoriteIds,
          onProductClick: (product: Product): void => {
            this.openDetail(product);
          }
        });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 20 });
    }
    .scrollBar(BarState.Off);
  }

  @Builder
  private favoritesTab() {
    Scroll() {
      Column({ space: 14 }) {
        this.hero('LAB 04   /   COLLECTION', '我的收藏', '本次运行已收藏 ' + this.favoriteIds.length.toString() + ' 件');
        if (this.favoriteIds.length === 0) {
          Column({ space: 8 }) {
            Text('还没有收藏').fontSize(17).fontWeight(FontWeight.Bold).fontColor(INK);
            Text('在商品详情选择收藏，再保存返回。').fontSize(13).fontColor(MUTED);
          }
          .width('100%')
          .padding(22)
          .backgroundColor(WHITE)
          .borderRadius(16);
        } else {
          ProductList({
            products: this.savedProducts(),
            favoriteIds: this.favoriteIds,
            onProductClick: (product: Product): void => {
              this.openDetail(product);
            }
          });
        }
        Button('切换到商品页签')
          .height(40)
          .backgroundColor(FOREST)
          .onClick((): void => {
            this.tabController.changeIndex(0);
          });
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 16, bottom: 20 });
    }
    .scrollBar(BarState.Off);
  }

  @Builder
  private tabLabel(label: string, index: number) {
    Column({ space: 4 }) {
      Text(index === this.selectedTab ? '●' : '○').fontSize(11)
        .fontColor(index === this.selectedTab ? FOREST : MUTED);
      Text(label).fontSize(13).fontWeight(index === this.selectedTab ? FontWeight.Bold : FontWeight.Regular)
        .fontColor(index === this.selectedTab ? FOREST : MUTED);
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center);
  }

  build() {
    Navigation(this.pathStack) {
      Tabs({ barPosition: BarPosition.End, index: this.selectedTab, controller: this.tabController }) {
        TabContent() {
          this.catalogTab();
        }
        .tabBar(this.tabLabel('商品', 0));
        TabContent() {
          this.favoritesTab();
        }
        .tabBar(this.tabLabel('收藏', 1));
      }
      .width('100%')
      .height('100%')
      .barHeight(56)
      .barBackgroundColor(WHITE)
      .divider({ strokeWidth: 1, color: LINE })
      .scrollable(false)
      .onChange((index: number): void => {
        this.selectedTab = index;
      });
    }
    .mode(NavigationMode.Stack)
    .hideTitleBar(true)
    .width('100%')
    .height('100%')
    .backgroundColor(PAPER);
  }
}
