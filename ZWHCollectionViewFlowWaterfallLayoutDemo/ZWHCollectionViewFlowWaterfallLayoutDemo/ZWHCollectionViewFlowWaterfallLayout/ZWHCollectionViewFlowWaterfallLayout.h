//
//  ZWHCollectionViewFlowWaterfallLayout.h
//
//  Created by ZWH on 2020/12/5.
//  Copyright © 2020. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

//备注： 使用方法，同UICollectionViewFlowLayout

//流布局代理 <协议>
@protocol ZWHCollectionViewFlowWaterfallLayoutDelegateFlowLayout <UICollectionViewDelegateFlowLayout>

@optional
//设置每个区的列数，默认2
- (NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnNumberAtSection:(NSInteger )section;

@end

@interface ZWHCollectionViewFlowWaterfallLayout : UICollectionViewFlowLayout

//列数 默认2
@property (nonatomic, assign) NSInteger columnCount;

@end

NS_ASSUME_NONNULL_END
