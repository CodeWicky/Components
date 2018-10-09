//
//  DWTwinkleView.m
//  DWTwinkleView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWTwinkleView.h"

typedef struct {
    int count;
    CGFloat spacing;
} DWTwinkleCal;

@interface DWTwinkleConfiguration ()

@property (nonatomic ,assign) DWTwinkleCal realHCal;

@property (nonatomic ,assign) DWTwinkleCal realVCal;

@end

@implementation DWTwinkleConfiguration

@end

@interface DWTwinkleView ()

@property (nonatomic ,strong) DWTwinkleConfiguration * config;

@property (nonatomic ,strong) NSMutableArray * items;

@property (nonatomic ,strong) NSTimer * timer;

@property (nonatomic ,assign) NSUInteger twinkleFlag;

@property (nonatomic ,assign) BOOL twinkling;

@property (nonatomic ,assign) CGFloat timeInterval;

@end

@implementation DWTwinkleView

-(instancetype)initWithFrame:(CGRect)frame configuration:(DWTwinkleConfiguration *)config {
    if (config.itemClass == NULL) {
        return nil;
    }
    id temp = [config.itemClass new];
    if (![temp isKindOfClass:[UIView class]] || ![temp conformsToProtocol:@protocol(DWTwinkleItemProtocol)]){
        return nil;
    }
    if (self = [super initWithFrame:frame]) {
        _config = config;
        [self configTwinkleWithSize:frame.size];
    }
    return self;
}

-(void)resizeTwinkleWithSize:(CGSize)size {
    [self configTwinkleWithSize:size];
}

-(void)startTwinkleWithInterval:(NSTimeInterval)time {
    id temp = [self.config.itemClass new];
    if (![temp respondsToSelector:@selector(updateTwinkleWithInfo:)]) {
        return;
    }
    if (self.timer) {
        [self.timer invalidate];
    }
    self.twinkling = YES;
    self.timeInterval = time;
    self.twinkleFlag = 0;
    self.timer = [NSTimer timerWithTimeInterval:time target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}

-(void)endTwinkle {
    [self.timer invalidate];
    self.timer = nil;
    self.twinkling = NO;
    self.timeInterval = 0;
    self.twinkleFlag = 0;
}

#pragma mark --- timerAction ---
-(void)timerAction:(UIButton *)sender {
    [self.items makeObjectsPerformSelector:@selector(updateTwinkleWithInfo:) withObject:@{@"flag":@(self.twinkleFlag),@"time":@(self.timeInterval)} ];
    ++self.twinkleFlag;
}

#pragma mark --- tool method ---
-(void)configTwinkleWithSize:(CGSize)size {
    CGFloat width = size.width - self.config.margin * 2;
    CGFloat height = size.height - self.config.margin * 2;
    
    ///如果去除margin后不合法隐藏
    if (width <= 0 || height <= 0 || width < self.config.itemSize.width * 2 || height < self.config.itemSize.height * 2) {
        self.config.realVCal = MDCalZero();
        self.config.realHCal = MDCalZero();
        [self hideTwinkleView];
        return;
    }
    
    ///计算布局
    self.config.realHCal = [self calForLength:width horizonal:YES];
    self.config.realVCal = [self calForLength:height horizonal:NO];
    
    ///布局
    [self layoutTwinkle];
}

-(void)layoutTwinkle {
    if (MDCalIsNull(self.config.realHCal) || MDCalIsNull(self.config.realVCal)) {
        [self hideTwinkleView];
        return;
    }
    
    ///记录当前状态后停止
    BOOL oriStatus = self.twinkling;
    CGFloat oriTime = self.timeInterval;
    [self endTwinkle];
    
    ///计算展示总数
    NSInteger total = (self.config.realVCal.count + self.config.realHCal.count) * 2 - 4;
    if (total <= 0) {
        [self hideTwinkleView];
        return;
    }
    //    [self.items makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //    [self.items removeAllObjects];
    ///处理总展示项目
    if (self.items.count < total) {
        [self addItemWithTotal:total];
    } else if (self.items.count > total) {
        [self removeExtraItemWithTotal:total];
    }
    
    ///重置所有cell的状态
    if ([self.items.firstObject respondsToSelector:@selector(resetItemStatusOnReLayout)]) {
        [self.items makeObjectsPerformSelector:@selector(resetItemStatusOnReLayout)];
    }
    
    ///处理所有item位置
    CGFloat itemW = self.config.itemSize.width;
    CGFloat itemH = self.config.itemSize.height;
    CGFloat spacingH = self.config.realHCal.spacing;
    CGFloat spacingV = self.config.realVCal.spacing;
    int countH = self.config.realHCal.count;
    int countV = self.config.realVCal.count;
    NSUInteger index = 0;
    
    ///顶边
    CGFloat startX = self.config.margin;
    CGFloat startY = self.config.margin;
    for (int i = 0; i < countH; ++i) {
        [self configItemWithFrame:CGRectMake(startX, startY, itemW, itemH) atIndex:index];
        index ++;
        startX += (itemW + spacingH);
    }
    
    ///右边
    startY += (itemH + spacingV);
    startX -= (itemW + spacingH);
    for (int i = 1; i < countV; ++i) {
        [self configItemWithFrame:CGRectMake(startX, startY, itemW, itemH) atIndex:index];
        index ++;
        startY += (itemH + spacingV);
    }
    
    ///底边
    startX -= (itemW + spacingH);
    startY -= (itemH + spacingV);
    for (int i = 1; i < countH; ++i) {
        [self configItemWithFrame:CGRectMake(startX, startY, itemW, itemH) atIndex:index];
        index ++;
        startX -= (itemW + spacingH);
    }
    
    ///左边
    startY -= (itemH + spacingV);
    startX += (itemW + spacingH);
    for (int i = 1; i < countV - 1; ++i) {
        [self configItemWithFrame:CGRectMake(startX, startY, itemW, itemH) atIndex:index];
        index ++;
        startY -= (itemH + spacingV);
    }
    
    ///如果重设前为闪烁状态则开始闪烁
    if (oriStatus && oriTime) {
        [self startTwinkleWithInterval:oriTime];
    }
}

-(void)removeExtraItemWithTotal:(NSUInteger)total {
    [self.items enumerateObjectsWithOptions:(NSEnumerationReverse) usingBlock:^(UIView * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx >= total) {
            [obj removeFromSuperview];
        } else {
            *stop = YES;
        }
    }];
    self.items = [[self.items subarrayWithRange:NSMakeRange(0, total)] mutableCopy];
}

-(void)addItemWithTotal:(NSUInteger)total {
    Class cls = self.config.itemClass;
    for (int i = (int)self.items.count; i < total; ++i) {
        UIView * item = (UIView *)[(id<DWTwinkleItemProtocol>)cls itemWithIndex:i];
        [self addSubview:item];
        [self.items addObject:item];
    }
}

-(void)configItemWithFrame:(CGRect)frame atIndex:(NSUInteger)index {
    if (index < self.items.count) {
        UIView * item = [self.items objectAtIndex:index];
        item.frame = frame;
    }
}

-(void)hideTwinkleView {
    [self endTwinkle];
}

-(DWTwinkleCal)calForLength:(CGFloat)length horizonal:(BOOL)horizonal {
    CGFloat realL = length - (horizonal?self.config.itemSize.width:self.config.itemSize.height);
    CGFloat itmL = horizonal?self.config.itemSize.width:self.config.itemSize.height;
    CGFloat spacing = self.config.spacing;
    int count = floor(length / (itmL + spacing));
    CGFloat delta = (realL - count * (itmL + spacing)) / count;
    if (delta == 0) {
        return (DWTwinkleCal){count + 1,spacing};
    }
    CGFloat fixDelta = spacing - (realL * 1.0 / (count + 1) - itmL);
    if (delta > fixDelta) {
        return (DWTwinkleCal){count + 1 + 1,spacing - fixDelta};
    } else {
        return (DWTwinkleCal){count + 1,spacing + delta};
    }
}

#pragma mark --- tool func ---
NS_INLINE BOOL MDCalIsNull(DWTwinkleCal cal) {
    return (cal.count == 0);
}

NS_INLINE DWTwinkleCal MDCalZero(void) {
    return (DWTwinkleCal){0,0};
}

#pragma mark --- setter/getter ---
-(NSMutableArray *)items {
    if (!_items) {
        _items = [NSMutableArray arrayWithCapacity:0];
    }
    return _items;
}

-(void)setFrame:(CGRect)frame {
    CGSize oriSize = self.frame.size;
    [super setFrame:frame];
    if (!CGSizeEqualToSize(oriSize, frame.size)) {
        [self resizeTwinkleWithSize:frame.size];
    }
}

@end
