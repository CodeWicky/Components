//
//  DWNoticeView.m
//  DWNoticeView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWNoticeView.h"

///判断是否实现了指定方法的宏
#define DWRespondTo(sel) (self.delegate && [(NSObject *)self.delegate conformsToProtocol:@protocol(DWNoticeViewDelegate)] && [(NSObject *)self.delegate respondsToSelector:sel])


@interface DWNoticeTableView : UITableView

@property (nonatomic ,assign) BOOL allowDidSelect;

@end

@implementation DWNoticeTableView

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView * ret = [super hitTest:point withEvent:event];
    if (self.allowDidSelect) {
        return ret;
    }
    if (!ret) {
        return nil;
    }
    if ([ret isEqual:self]) {
        return nil;
    }
    return ret;
}

@end


@interface DWNoticeView ()<UITableViewDelegate,UITableViewDataSource>
/**
 内部实际展示的tabV
 */
@property (nonatomic ,strong) DWNoticeTableView * tabV;
/**
 默认的轮播间隔
 */
@property (nonatomic ,assign) NSTimeInterval timeInterval;
/**
 是否正在轮播
 */
@property (nonatomic ,assign ,getter=isPlaying) BOOL playing;
/**
 当前正在展示的角标
 */
@property (nonatomic ,assign) NSUInteger currentIndex;

@end

@implementation DWNoticeView

#pragma mark --- interface method ---
-(instancetype)initWithFrame:(CGRect)frame timeInterval:(NSTimeInterval)timeInterval {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tabV];
        _timeInterval = timeInterval;
    }
    return self;
}

-(void)registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)cellID {
    [_tabV registerClass:cellClass forCellReuseIdentifier:cellID];
}

-(UITableViewCell *)cellForRowAtIndex:(NSUInteger)index {
    return [_tabV cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
}

-(void)play {
    NSUInteger max = [_tabV numberOfRowsInSection:0];
    ///如果没有或者只有1个不轮播
    if (max == 0 || max == 1) {
        return;
    }
    if (self.isPlaying) {
        return;
    }
    self.playing = YES;
    UITableViewCell * c = [self cellForRowAtIndex:self.currentIndex];
    if (c && DWRespondTo(@selector(banner:didDisplayCell:atIndex:))) {
        [self.delegate banner:self didDisplayCell:c atIndex:self.currentIndex];
    }
    [self doPlay];
}

-(void)stop {
    if (!self.isPlaying) {
        return;
    }
    self.playing = NO;
}

-(void)reloadData {
    [_tabV reloadData];
}

-(UITableViewCell *)dequeueCellForID:(NSString *)cellID atIndex:(NSUInteger)index flag:(BOOL)flag {
    NSUInteger idx = index;
    if (flag) {
        idx += [self.delegate numberOfRowsForBanner:self];
    }
    return [_tabV dequeueReusableCellWithIdentifier:cellID forIndexPath:[NSIndexPath indexPathForRow:idx inSection:0]];
}

#pragma mark --- tool method ---
///返回对应角标的展示时长
-(NSTimeInterval)timeIntervalForCellAtIndex:(NSUInteger)index {
    if (DWRespondTo(@selector(banner:timeIntervalForCellAtIndex:))) {
        return [self.delegate banner:self timeIntervalForCellAtIndex:index];
    } else {
        return self.timeInterval;
    }
}

///通过递归调用不断切换展示cell
-(void)doPlay {
    
    if (self.isPlaying) {
        NSUInteger max = [_tabV numberOfRowsInSection:0];
        if (max == 0) {
            [self stop];
            return;
        }
        ///内部处理实际比外部传入总数多1，为占位cell，故此处若为占位cell展示时长应为第一个cell的时长
        NSTimeInterval time = [self timeIntervalForCellAtIndex:(self.currentIndex == max - 1)?0:self.currentIndex];
        ///此处实现让cell可以滚动至占位cell，滚动结束后如果检测到当前为占位cell则立即无动画切换至首位cell，此处处理方式及常规banner方式
        __weak typeof(self)weakSelf = self;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (weakSelf.isPlaying) {
                NSUInteger target = weakSelf.currentIndex + 1;
                if (target >= max) {
                    target = 0;
                }
                [weakSelf scrollToIndex:target animate:YES];
                [weakSelf doPlay];
            }
        });
    }
}

-(void)scrollToIndex:(NSUInteger)index animate:(BOOL)animate {
    self.currentIndex = index;
    [_tabV scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0] atScrollPosition:(UITableViewScrollPositionMiddle) animated:animate];
}

#pragma mark --- tableView delegate ---
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    ///如果本身就不存在数据则不需要占位数据
    NSUInteger count = [self.delegate numberOfRowsForBanner:self];
    if (count == 0) {
        return 0;
    }
    return count + 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ///此处应将占位数据映射为首位数据由外界进行处理，以隐藏实现细节
    NSUInteger count = [self.delegate numberOfRowsForBanner:self];
    NSUInteger index = (indexPath.row % count);
    BOOL flag = indexPath.row >= count;
    UITableViewCell * cell = [self.delegate banner:self cellForRowAtIndex:index flag:flag];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (DWRespondTo(@selector(banner:didSelectRowAtIndex:))) {
        NSUInteger max = [_tabV numberOfRowsInSection:0];
        ///若为占位角标，则转换为首位角标
        NSUInteger index = (indexPath.row  == max - 1)?0:indexPath.row;
        [self.delegate banner:self didSelectRowAtIndex:index];
    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    ///如果展示的是占位cell，则立即无动画切换至首位
    if (self.currentIndex >= [_tabV numberOfRowsInSection:0] - 1) {
        [self scrollToIndex:0 animate:NO];
        if (DWRespondTo(@selector(banner:didDisplayCell:atIndex:))) {
            [self.delegate banner:self didDisplayCell:[self cellForRowAtIndex:0] atIndex:0];
        }
    } else {
        if (DWRespondTo(@selector(banner:didDisplayCell:atIndex:))) {
            [self.delegate banner:self didDisplayCell:[self cellForRowAtIndex:self.currentIndex] atIndex:self.currentIndex];
        }
    }
}

#pragma mark --- override ---
-(void)setFrame:(CGRect)frame {
    if (!CGRectEqualToRect(frame, self.frame)) {
        [super setFrame:frame];
        _tabV.frame = self.bounds;
        _tabV.rowHeight = self.bounds.size.height;
    }
}

#pragma mark --- setter/getter ---
-(UITableView *)tabV {
    if (!_tabV) {
        _tabV = [[DWNoticeTableView alloc] initWithFrame:self.bounds style:(UITableViewStylePlain)];
        _tabV.rowHeight = self.bounds.size.height;
        _tabV.backgroundColor = [UIColor clearColor];
        _tabV.showsVerticalScrollIndicator = NO;
        _tabV.showsHorizontalScrollIndicator = NO;
        _tabV.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tabV.allowsSelection = NO;
        _tabV.delegate = self;
        _tabV.dataSource = self;
        _tabV.scrollEnabled = NO;
    }
    return _tabV;
}
@end
