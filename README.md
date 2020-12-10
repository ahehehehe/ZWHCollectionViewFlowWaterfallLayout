# ZWHCollectionViewFlowWaterfallLayout
CollectionView瀑布流+悬停布局(参考了CHTCollectionViewWaterfallLayout）

要求
iOS 9.0+
Xcode 9+
Objective-C

安装
手动
Clone 代码，把 ZWHCollectionViewFlowWaterfallLayout 文件夹拖入项目，#import "ZWHCollectionViewFlowWaterfallLayout" 就可以使用了。

使用
用法基本同UICollectionViewFlowLayout
阅读演示代码和 ZWHCollectionViewFlowWaterfallLayout.h头文件以获取更多信息。

下面列出了可用于自定义布局的属性:
//列数 默认2
@property (nonatomic, assign) NSInteger columnCount;

//设置不同section的显示列数
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnNumberAtSection:(NSInteger )section;
