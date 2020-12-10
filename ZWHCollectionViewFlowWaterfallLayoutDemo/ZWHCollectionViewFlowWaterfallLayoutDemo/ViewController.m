//
//  ViewController.m
//  ZWHCollectionViewFlowWaterfallLayoutDemo
//
//  Created by  on 2020/12/9.
//

#import "ViewController.h"
#import "ZWHCollectionViewFlowWaterfallLayout.h"

static NSString * ID = @"ijisjdiojsidhgyufwgeuygvsoiwehwe";

static NSString * kFooter = @"kFooter";
static NSString * kHeader = @"kHeader";

@interface ViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,ZWHCollectionViewFlowWaterfallLayoutDelegateFlowLayout>

@property (nonatomic,strong) UICollectionView *collectionView;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
   
    [self CreatCollectionView];
    
}
-(void)CreatCollectionView{
    
    [self.view addSubview:self.collectionView];
    self.collectionView.frame = CGRectMake(0, 60, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height-88);
    
}
#pragma mark 设置每个区的列数
-(NSInteger)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout columnNumberAtSection:(NSInteger)section{

    if (section == 0) {
        return 2;
    }else if (section == 1){
        return 4;
    }else if (section == 2){
        return 3;
    }else if (section == 3){
        return 5;
    }
    return 2;
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    //设置分组的数量
    return 6;
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (section == 0) {
        return 3;
    }else if (section == 1){
        return 9;
    }else if (section == 2){
        return 11;
    }
    return 5;
}
#pragma mark 宽度可随便设置，默认均分
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.section == 0) {
        if (indexPath.item == 0) {
            return CGSizeMake(300, 120);
        } else {
            return CGSizeMake(200, 40);
        }
    }else if (indexPath.section == 1){
        if (indexPath.item == 0) {
            return CGSizeMake(100, 70);
        }else if (indexPath.item == 1) {
            return CGSizeMake(200, 50);
        }
        return CGSizeMake(200, 60);
    }else if (indexPath.section == 2){
        if (indexPath.item == 0) {
            return CGSizeMake(100, 20);
        }else if (indexPath.item == 1) {
            return CGSizeMake(200, 60);
        }
        return CGSizeMake(200, 90);
    }
    return CGSizeMake(200, 40);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        //设置段头的大小,如果滑动方向是纵向，宽度设置无效
        return CGSizeMake([UIScreen mainScreen].bounds.size.width, 40);
    }
    //设置段头的大小,如果滑动方向是纵向，宽度设置无效
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 80);
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section{
    //设置段头的大小,如果滑动方向是纵向，宽度设置无效
    return CGSizeMake([UIScreen mainScreen].bounds.size.width, 40);
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    //设置和collectionView滑动方向不一致的方向的最小间隔
    
    return 12;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    //设置和collectionView滑动方向一致的方向的间隔
    return 12;
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    
    return UIEdgeInsetsMake(12, 12, 12, 12);
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSLog(@"点击了：%ld--%ld",(long)indexPath.section,(long)indexPath.item);
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    UICollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:ID forIndexPath:indexPath];
    
    cell.contentView.backgroundColor = [UIColor orangeColor];
    
    
    return cell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableView = nil;
    if([kind isEqualToString:UICollectionElementKindSectionHeader]){
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeader forIndexPath:indexPath];
        header.backgroundColor = [UIColor redColor];
        return header;
    }
    else{
        UICollectionReusableView *header = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooter forIndexPath:indexPath];
        header.backgroundColor = [UIColor greenColor];
        return header;

    }
    return reusableView;
}

-(UICollectionView *)collectionView{
    if (_collectionView == nil) {
        ZWHCollectionViewFlowWaterfallLayout *flowLayout = [[ZWHCollectionViewFlowWaterfallLayout alloc] init];
        flowLayout.sectionHeadersPinToVisibleBounds = YES;//头视图悬浮
//        flowLayout.sectionFootersPinToVisibleBounds = YES;//头视图悬浮

        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        // 注册cell
        [_collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:ID];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kHeader];
        [_collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionFooter withReuseIdentifier:kFooter];
        
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        
        _collectionView.backgroundColor = [UIColor whiteColor];
        
    }
    return _collectionView;
}


@end
