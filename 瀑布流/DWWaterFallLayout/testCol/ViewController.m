//
//  ViewController.m
//  testCol
//
//  Created by Wicky on 2018/11/29.
//  Copyright © 2018 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWWaterFallLayout.h"
#import "ItemModel.h"

@interface ViewController ()<UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>

@property (nonatomic ,strong) UICollectionView * colV;

@property (nonatomic ,strong) UICollectionViewLayout * layout;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self setupData];
    [self setupUI];
    
    
}

-(void)setupData {
    while (self.dataArr.count < 36) {
        ItemModel * m = [ItemModel new];
        m.originSize = CGSizeMake(arc4random_uniform(100) + 100, arc4random_uniform(100) + 100);
        [self.dataArr addObject:m];
    }
}

-(void)setupUI {
    [self.view addSubview:self.colV];
}

#pragma mark --- delegate ---
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell * c = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    c.backgroundColor = [UIColor redColor];
    return c;
}

#pragma mark --- setter/getter ---
-(UICollectionViewLayout *)layout {
    if (!_layout) {
        UICollectionViewFlowLayout * tmp = [UICollectionViewFlowLayout new];
        tmp.minimumInteritemSpacing = 100;
        tmp.itemSize = CGSizeMake(200, 200);
        DWWaterFallLayout * l = [DWWaterFallLayout new];
        l.items = self.dataArr;
        l.lineSpacing = 10;
        l.interitemSpacing = 10;
        l.columnCount = 6;
        l.edgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
        l.direction = DWWaterFallLayoutDirectionHorizontal;
        _layout = l;
    }
    return _layout;
}

-(UICollectionView *)colV {
    if (!_colV) {
        _colV = [[UICollectionView alloc] initWithFrame:self.view.frame collectionViewLayout:self.layout];
        _colV.delegate = self;
        _colV.dataSource = self;
        [_colV registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"cell"];
        _colV.backgroundColor = [UIColor lightGrayColor];
        _colV.alwaysBounceHorizontal = YES;
        _colV.alwaysBounceVertical = YES;
    }
    return _colV;
}

-(NSMutableArray *)dataArr {
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithCapacity:0];
    }
    return _dataArr;
}

@end
