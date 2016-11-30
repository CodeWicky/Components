//
//  DWNewsView.m
//  DWNewsView
//
//  Created by Wicky on 2016/11/30.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWNewsView.h"

@interface DWNewsViewCell : UICollectionViewCell

@property (nonatomic ,copy) NSString * news;

@property (nonatomic ,strong) UILabel * newsLabel;

@end

@implementation DWNewsViewCell

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    self.newsLabel = [[UILabel alloc] init];
    [self.contentView addSubview:self.newsLabel];
}

-(void)setNews:(NSString *)news
{
    _news = news;
    self.newsLabel.text = news;
    [self.newsLabel sizeToFit];
    CGPoint center = self.newsLabel.center;
    center.y = self.frame.size.height / 2.0;
    self.newsLabel.center = center;
}

@end

@interface DWNewsView ()<UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,CAAnimationDelegate>

@property (nonatomic ,strong) UICollectionView * colV;

@property (nonatomic ,strong) NSTimer * timer;

@property (nonatomic ,assign) NSTimeInterval timerInterval;

@property (nonatomic ,strong) NSMutableArray * dataArr;

@property (nonatomic ,strong) UILabel * lastLabel;

@property (nonatomic ,copy) void (^clickBlock)(NSInteger,NSString *);

@property (nonatomic ,assign) BOOL firstCell;

@end

@implementation DWNewsView

@synthesize textColor = _textColor;
@synthesize font = _font;

#pragma mark ---接口方法---
-(instancetype)initWithFrame:(CGRect)frame
                        news:(NSArray<NSString *> *)news
                timeInterval:(NSTimeInterval)timeInterval
                       speed:(CGFloat)speed
                  clickBlock:(void (^)(NSInteger, NSString *))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        _news = news;
        _timerInterval = timeInterval;
        _clickBlock = handler;
        _speed = speed;
        _firstCell = YES;
        [self setupUI];
    }
    return self;
}

-(void)invalidateNewsView
{
    [self.timer invalidate];
    [self removeFromSuperview];
}
#pragma mark ---工具方法---
///设置UI
-(void)setupUI
{
    UICollectionViewFlowLayout * layout = [[UICollectionViewFlowLayout alloc] init];
    layout.itemSize = self.bounds.size;
    layout.minimumLineSpacing = 0;
    layout.minimumInteritemSpacing = 0;
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    self.colV = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:layout];
    [self addSubview:self.colV];
    self.colV.backgroundColor = self.backgroundColor;
    self.colV.scrollEnabled = NO;
    self.colV.pagingEnabled = YES;
    self.colV.showsVerticalScrollIndicator = NO;
    [self.colV registerClass:[DWNewsViewCell class] forCellWithReuseIdentifier:@"DWNewsViewCell"];
    self.colV.delegate = self;
    self.colV.dataSource = self;
}

///创建计时器
-(void)createTimer
{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:self.timerInterval target:self selector:@selector(changeNews) userInfo:nil repeats:YES];
}

///更改当前项
-(void)changeNews
{
    CGPoint offset = self.colV.contentOffset;
    offset.y += self.bounds.size.height;
    [self.colV setContentOffset:offset animated:YES];
}

///滚动结束处理动画逻辑
-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
    NSInteger currentIndex = self.colV.contentOffset.y / self.bounds.size.height;
    DWNewsViewCell * cell = (DWNewsViewCell *)[self.colV cellForItemAtIndexPath:[NSIndexPath indexPathForItem:currentIndex inSection:0]];
    [self handleAnimationForCell:cell];
}

///为cell添加label动画
-(void)handleAnimationForCell:(DWNewsViewCell *)cell
{
    CGFloat deltaLength = cell.newsLabel.bounds.size.width - self.bounds.size.width;///计算偏移长度
    [self.lastLabel.layer removeAnimationForKey:@"position"];
    if (deltaLength > 0 && self.speed > 0) {
        [self.timer setFireDate:[NSDate distantFuture]];///暂停计时器
        CGFloat duration = deltaLength / self.speed;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{///偏移动画
            CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"position"];
            animation.duration = duration;
            animation.delegate = self;
            animation.removedOnCompletion = NO;
            animation.fillMode = kCAFillModeForwards;
            CGPoint position = cell.newsLabel.layer.position;
            position.x -= deltaLength;
            animation.toValue = [NSValue valueWithCGPoint:position];
            [cell.newsLabel.layer addAnimation:animation forKey:@"position"];
            self.lastLabel = cell.newsLabel;
        });
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.colV.contentOffset.y >= self.news.count * self.bounds.size.height) {
            [self.colV setContentOffset:CGPointZero animated:NO];
        }
        ///如果是第一个cell展示动画完成，添加计时器
        if (self.firstCell) {
            [self createTimer];
            self.firstCell = NO;
        }
        [self.timer setFireDate:[NSDate distantPast]];///恢复计时器
    });
}

///处理第一个cell展示动画
-(void)collectionView:(UICollectionView *)collectionView willDisplayCell:(DWNewsViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.firstCell && indexPath.row == 0) {
        [self handleAnimationForCell:cell];
    }
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataArr.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DWNewsViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DWNewsViewCell" forIndexPath:indexPath];
    cell.newsLabel.textColor = self.textColor;
    cell.newsLabel.font = self.font;
    cell.news = self.dataArr[indexPath.row];
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.clickBlock) {
        self.clickBlock(indexPath.row,self.dataArr[indexPath.row]);
    }
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.colV.backgroundColor = self.backgroundColor;
}

-(void)setTextColor:(UIColor *)textColor
{
    _textColor = textColor;
    [self.colV reloadData];
}

-(UIColor *)textColor
{
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

-(void)setFont:(UIFont *)font
{
    _font = font;
    [self.colV reloadData];
}

-(UIFont *)font
{
    if (!_font) {
        _font = [UIFont systemFontOfSize:17];
    }
    return _font;
}

-(NSMutableArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSMutableArray arrayWithArray:self.news];
        if (self.news.count) {
            [_dataArr addObject:self.news.firstObject];
        }
    }
    return _dataArr;
}

@end
