//
//  ZWHCollectionViewFlowWaterfallLayout.m
//
//  Created by ZWH on 2020/12/5.
//  Copyright © 2020 . All rights reserved.
//

#import "ZWHCollectionViewFlowWaterfallLayout.h"

@interface ZWHCollectionViewFlowWaterfallLayout ()

@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesHeaderArray;
@property (nonatomic, strong) NSMutableArray<NSArray<UICollectionViewLayoutAttributes *> *> *attributesSectionArray;
@property (nonatomic, strong) NSMutableArray<UICollectionViewLayoutAttributes *> *attributesFooterArray;
/** 瀑布流布局 记录当前section每一列的高度 */
@property (nonatomic, strong) NSMutableArray *sectionColumnHeightArray;

@property (nonatomic, weak) id<ZWHCollectionViewFlowWaterfallLayoutDelegateFlowLayout> delegate;

@end

@implementation ZWHCollectionViewFlowWaterfallLayout

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self makeUI];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self makeUI];
    }
    return self;
}

-(void)makeUI{
    _columnCount = 2;
    
}
-(void)setColumnCount:(NSInteger)columnCount{
    _columnCount = columnCount;
}

//自定义layout需要重写这些方法
-(void)prepareLayout{
    [super prepareLayout];
    
    [self.attributesHeaderArray removeAllObjects];
    [self.attributesSectionArray removeAllObjects];
    [self.attributesFooterArray removeAllObjects];
    [self.sectionColumnHeightArray removeAllObjects];
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return;
    }
    
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSInteger columnCount = [self columnCountForSection:section];
        NSMutableArray *sectionColumnHeights = [NSMutableArray arrayWithCapacity:columnCount];
        for (NSInteger idx = 0; idx < columnCount; idx++) {
            [sectionColumnHeights addObject:@(0)];
        }
        [self.sectionColumnHeightArray addObject:sectionColumnHeights];
    }
    
    CGFloat top = 0;
    for (NSInteger section = 0; section < numberOfSections; section++) {
        NSUInteger    columnCount = [self columnCountForSection:section]; // 列数
        CGFloat       minimumLineSpacing = self.minimumLineSpacing;
        CGFloat       minimumInteritemSpacing = self.minimumInteritemSpacing;
        CGFloat       itemHeight = self.itemSize.height;
        CGFloat       itemWidth = self.itemSize.width;
        CGSize        headerReferenceSize = self.headerReferenceSize;
        CGSize        footerReferenceSize = self.footerReferenceSize;
        UIEdgeInsets  sectionInset = self.sectionInset;
        
        // 内间距
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
            sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
        }
        
        // 行距
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumLineSpacingForSectionAtIndex:)]) {
            minimumLineSpacing = [self.delegate collectionView:self.collectionView layout:self minimumLineSpacingForSectionAtIndex:section];
        }
        // 列距
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:minimumInteritemSpacingForSectionAtIndex:)]) {
            minimumInteritemSpacing = [self.delegate collectionView:self.collectionView layout:self minimumInteritemSpacingForSectionAtIndex:section];
        }
        // 组头
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForHeaderInSection:)]) {
            headerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForHeaderInSection:section];
        }
        // 组wei
        if ([self.delegate respondsToSelector:@selector(collectionView:layout:referenceSizeForFooterInSection:)]) {
            footerReferenceSize = [self.delegate collectionView:self.collectionView layout:self referenceSizeForFooterInSection:section];
        }
        
        
        /*
         * Section header
         */
        if (headerReferenceSize.height>0) {
            UICollectionViewLayoutAttributes *headerAttributs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            headerAttributs.frame = CGRectMake(0, top, headerReferenceSize.width, headerReferenceSize.height);
            [self.attributesHeaderArray addObject:headerAttributs];
            top = CGRectGetMaxY(headerAttributs.frame);
        }
        
        
        //添加区的顶部内间距
        for (NSInteger i = 0; i < columnCount; i++) {
            self.sectionColumnHeightArray[section][i] = @(top+sectionInset.top);
        }
        
        /*
         * 3. Section items
         */
        NSInteger itemCountOfSection = [self.collectionView numberOfItemsInSection:section];
        NSMutableArray *attributesArray = [NSMutableArray arrayWithCapacity:itemCountOfSection];
        
        for (NSInteger item = 0; item < itemCountOfSection; item++) {
            
            NSIndexPath * itemIndexPath = [NSIndexPath indexPathForItem:item inSection:section];
            // item的宽度
            itemWidth = (self.collectionView.bounds.size.width - sectionInset.left - sectionInset.right-(columnCount-1)*minimumInteritemSpacing)/columnCount;
            
            // item的高度
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)]) {
                itemHeight = [self.delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:itemIndexPath].height;
            }
            
            CGFloat itemX = 0;
            CGFloat itemY = 0;
            
            // 找出最短的那一列
            NSUInteger minIndex = [self shortestColumnIndexInSection:section];
            
            // 根据最短列的列数计算item的x值
            itemX = sectionInset.left + (minimumInteritemSpacing + itemWidth) * minIndex;
            // item的y值
            itemY = [self.sectionColumnHeightArray[section][minIndex] floatValue];
            
            UICollectionViewLayoutAttributes *attributess = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:itemIndexPath];
            // 更新字典中的最大y值
            attributess.frame = CGRectMake(itemX, itemY, itemWidth, itemHeight);
            [attributesArray addObject:attributess];
            self.sectionColumnHeightArray[section][minIndex] = @(CGRectGetMaxY(attributess.frame) + minimumInteritemSpacing);
        }
        
        [self.attributesSectionArray addObject:attributesArray];
        
        
        /*
         * 4. Section footer
         */
        
        // 遍历字典，找出最长的值
        NSUInteger columnIndex = [self longestColumnIndexInSection:section];
        
        if (((NSArray *)self.sectionColumnHeightArray[section]).count > 0) {
            top = [self.sectionColumnHeightArray[section][columnIndex] floatValue] - minimumInteritemSpacing + sectionInset.bottom;
        } else {
            top = 0;
        }
        if (footerReferenceSize.height>0) {
            UICollectionViewLayoutAttributes *footerAttributs = [UICollectionViewLayoutAttributes layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter withIndexPath:[NSIndexPath indexPathForItem:0 inSection:section]];
            footerAttributs.frame = CGRectMake(0, top, footerReferenceSize.width, footerReferenceSize.height);
            [self.attributesFooterArray addObject:footerAttributs];
            top = CGRectGetMaxY(footerAttributs.frame);
        }
        
        for (NSInteger i = 0; i < columnCount; i++) {
            self.sectionColumnHeightArray[section][i] = @(top + sectionInset.top);
        }
        
    }
    
}
#pragma mark 查找最长
- (NSUInteger)longestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat longestHeight = 0;
    
    [self.sectionColumnHeightArray[section] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        CGFloat temp = [obj floatValue];
        if (longestHeight < temp) {
            longestHeight = temp;
            index = idx;
        }
    }];
    
    return index;
}
#pragma mark 查找最短
- (NSUInteger)shortestColumnIndexInSection:(NSInteger)section {
    __block NSUInteger index = 0;
    __block CGFloat shortestHeight = MAXFLOAT;
    
    [self.sectionColumnHeightArray[section] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGFloat temp = [obj floatValue];
        if (temp < shortestHeight) {
            shortestHeight = temp;
            index = idx;
        }
    }];
    
    return index;
}


//返回collectionView的内容的尺寸
-(CGSize)collectionViewContentSize{
    
    NSInteger numberOfSections = [self.collectionView numberOfSections];
    if (numberOfSections == 0) {
        return CGSizeZero;
    }
    
    CGFloat maxColH = [[[self.sectionColumnHeightArray lastObject] firstObject] floatValue];
    for (NSNumber * num in [self.sectionColumnHeightArray lastObject]) {
        CGFloat temp = [num floatValue];
        if(maxColH < temp){
            maxColH= temp;
        }
    }
    return CGSizeMake(self.collectionView.frame.size.width, maxColH + self.sectionInset.bottom);
}

//- 作用：
// - 这个方法的返回值是个数组
// - 这个数组中存放的都是UICollectionViewLayoutAttributes对象
// - UICollectionViewLayoutAttributes对象决定了cell的排布方式（frame等）
- (NSArray<__kindof UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect{
    
    NSMutableArray<UICollectionViewLayoutAttributes *> *layoutAttributesArray = [NSMutableArray array];
    [self.attributesHeaderArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [layoutAttributesArray addObject:obj];
        }
    }];
    [self.attributesSectionArray enumerateObjectsUsingBlock:^(NSArray<UICollectionViewLayoutAttributes *> * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (CGRectIntersectsRect(obj.frame, rect)) {
                [layoutAttributesArray addObject:obj];
            }
        }];
    }];
    [self.attributesFooterArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (CGRectIntersectsRect(obj.frame, rect)) {
            [layoutAttributesArray addObject:obj];
        }
    }];
    if (!self.sectionHeadersPinToVisibleBounds && !self.sectionFootersPinToVisibleBounds) {
        return layoutAttributesArray;
    }
    
    //悬停处理
    CGPoint const contentOffset = self.collectionView.contentOffset;
    NSMutableIndexSet *missingSections = [NSMutableIndexSet indexSet];
    
    [layoutAttributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (obj.representedElementCategory == UICollectionElementCategoryCell) {
            [missingSections addIndex:obj.indexPath.section];
        }
    }];
    if (self.sectionHeadersPinToVisibleBounds) {
        
        //再从里面删除所有UICollectionElementKindSectionHeader类型的cell
        [layoutAttributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [missingSections removeIndex:obj.indexPath.section];
            }
        }];
        
        //对rect外的Header生成attributes 加入Attributes数组
        [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *layoutAttributesHeader = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionHeader atIndexPath:indexPath];
            
            if (layoutAttributesHeader) {
                [layoutAttributesArray addObject:layoutAttributesHeader];
            }
        }];
    }
    
    if (self.sectionFootersPinToVisibleBounds) {
        
        //再从里面删除所有UICollectionElementKindSectionFooter类型的cell
        [layoutAttributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]) {
                [missingSections removeIndex:obj.indexPath.section];
            }
        }];
        
        //对rect外的Footer生成attributes 加入Attributes数组
        [missingSections enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:idx];
            UICollectionViewLayoutAttributes *layoutAttributesFooter = [self layoutAttributesForSupplementaryViewOfKind:UICollectionElementKindSectionFooter atIndexPath:indexPath];
            if (layoutAttributesFooter) {
                [layoutAttributesArray addObject:layoutAttributesFooter];
            }
        }];
    }
    
    [layoutAttributesArray enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        //从layoutAttributesArr中储存的布局信息中，针对UICollectionElementKindSectionHeader
        if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionHeader] && self.sectionHeadersPinToVisibleBounds){
            NSInteger section = obj.indexPath.section;
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            
            // 针对当前layoutAttributes的section， 找出第一个和最底部一个普通cell的位置
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            
            __block UICollectionViewLayoutAttributes *bottomCellAttrs;
            __block NSUInteger index = 0;
            [self.attributesSectionArray[section] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (CGRectGetMaxY(bottomCellAttrs.frame) < CGRectGetMaxY(obj.frame)) {
                    bottomCellAttrs = obj;
                    index = idx;
                }
            }];
            
            
            //内间距
            UIEdgeInsets sectionInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            } else {
                sectionInset = self.sectionInset;
            }
            //获取当前header的frame
            CGRect rect = obj.frame;
            //第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
            CGFloat headerY = CGRectGetMinY(firstCellAttrs.frame) - sectionInset.top - rect.size.height;
            //哪个大取哪个，保证header悬停
            //针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
            CGFloat maxY = MAX(contentOffset.y,headerY);
            
            CGPoint origin = rect.origin;
            NSLog(@"11111-----%.2f",origin.y);
            origin.y = MIN(maxY,CGRectGetMaxY(bottomCellAttrs.frame) + sectionInset.bottom - rect.size.height);
            rect.origin = origin;
            NSLog(@"22222-----%.2f",origin.y);
            obj.zIndex = 1024;
            obj.frame = rect;
            
            
        }else if ([obj.representedElementKind isEqualToString:UICollectionElementKindSectionFooter] && self.sectionFootersPinToVisibleBounds){
            NSInteger section = obj.indexPath.section;
            
            NSIndexPath *firstCellIndexPath = [NSIndexPath indexPathForItem:0 inSection:section];
            
            //针对当前layoutAttributes的section， 找出第一个和最底部一个普通cell的位置
            
            UICollectionViewLayoutAttributes *firstCellAttrs = [self layoutAttributesForItemAtIndexPath:firstCellIndexPath];
            
            __block UICollectionViewLayoutAttributes *bottomCellAttrs;
            [self.attributesSectionArray[section] enumerateObjectsUsingBlock:^(UICollectionViewLayoutAttributes * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if (CGRectGetMaxY(bottomCellAttrs.frame) < CGRectGetMaxY(obj.frame)) {
                    bottomCellAttrs = obj;
                }
            }];
            
            //内间距
            UIEdgeInsets sectionInset;
            if ([self.delegate respondsToSelector:@selector(collectionView:layout:insetForSectionAtIndex:)]) {
                sectionInset = [self.delegate collectionView:self.collectionView layout:self insetForSectionAtIndex:section];
            } else {
                sectionInset = self.sectionInset;
            }
            //获取当前header的frame
            CGRect rect = obj.frame;
            //第一个cell的y值 - 当前header的高度 - 可能存在的sectionInset的top
            CGFloat headerY = CGRectGetMaxY(bottomCellAttrs.frame)+ sectionInset.bottom;
            //哪个大取哪个，保证header悬停
            //针对当前header基本上都是offset更加大，针对下一个header则会是headerY大，各自处理
            CGFloat minY = MIN(contentOffset.y  + self.collectionView.bounds.size.height - rect.size.height,headerY);
            
            CGPoint origin = obj.frame.origin;
            origin.y = MAX(minY,CGRectGetMinY(firstCellAttrs.frame) - sectionInset.top);
            
            rect.origin = origin;
            
            obj.zIndex = 1024;
            obj.frame = rect;
        }
        
    }];
    
    return layoutAttributesArray;
}
////自定义cell布局的时候重写
////返回对应于indexPath的位置的cell的布局属性,返回指定indexPath的item的布局信息。子类必须重载该方法,该方法只能为cell提供布局信息，不能为补充视图和装饰视图提供。
- (UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.section < self.attributesSectionArray.count) {
        if (indexPath.item < self.attributesSectionArray[indexPath.section].count) {
            return self.attributesSectionArray[indexPath.section][indexPath.item];
        }
    }
    return nil;
    
}
////自定义SupplementaryView的时候重写
- (UICollectionViewLayoutAttributes *)layoutAttributesForSupplementaryViewOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath{
    UICollectionViewLayoutAttributes *attribute = nil;
    if ([elementKind isEqualToString:UICollectionElementKindSectionHeader]) {
        if (self.attributesHeaderArray.count>0) {
            attribute = self.attributesHeaderArray[indexPath.section];
        }
    } else if ([elementKind isEqualToString:UICollectionElementKindSectionFooter]) {
        if (self.attributesFooterArray.count>0) {
            attribute = self.attributesFooterArray[indexPath.section];
        }
    }
    return attribute;
}
- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    [self invalidateLayout];
    return YES;
}


// 列数
- (NSInteger)columnCountForSection:(NSInteger)section {
    if ([self.delegate respondsToSelector:@selector(collectionView:layout:columnNumberAtSection:)]) {
        self.columnCount = [self.delegate collectionView:self.collectionView layout:self columnNumberAtSection:section];
    }
    return self.columnCount;
}

-(NSMutableArray<UICollectionViewLayoutAttributes *> *)attributesHeaderArray{
    if (_attributesHeaderArray==nil) {
        _attributesHeaderArray = [NSMutableArray array];
    }
    return _attributesHeaderArray;
}
-(NSMutableArray<NSArray<UICollectionViewLayoutAttributes *> *> *)attributesSectionArray{
    if (_attributesSectionArray==nil) {
        _attributesSectionArray = [NSMutableArray array];
    }
    return _attributesSectionArray;
}
-(NSMutableArray<UICollectionViewLayoutAttributes *> *)attributesFooterArray{
    if (_attributesFooterArray==nil) {
        _attributesFooterArray = [NSMutableArray array];
    }
    return _attributesFooterArray;
}
-(NSMutableArray *)sectionColumnHeightArray{
    if (_sectionColumnHeightArray == nil) {
        _sectionColumnHeightArray = [NSMutableArray array];
    }
    return _sectionColumnHeightArray;
}

- (id <ZWHCollectionViewFlowWaterfallLayoutDelegateFlowLayout> )delegate {
    return (id <ZWHCollectionViewFlowWaterfallLayoutDelegateFlowLayout> )self.collectionView.delegate;
}

@end
