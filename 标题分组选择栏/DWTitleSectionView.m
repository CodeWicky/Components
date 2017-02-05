//
//  DWTitleSectionView.m
//  DWCountdownButton
//
//  Created by Wicky on 2017/2/5.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWTitleSectionView.h"

#define TagOffset 10000
#define SeperatorColor [UIColor lightGrayColor].CGColor
#define SeperatorLineMargin (self.bounds.size.height / 10.0)
#define IndicatorColor DefaultHighlightColor.CGColor
#define IndicatorMargin 10
#define IndicatorHeight 5

@interface DWTitleSectionView ()

@property (nonatomic ,copy) void (^handler)(NSUInteger idx,NSString * title,UIButton * btn);

@property (nonatomic ,strong) NSArray<UIButton *> * btnArr;

@property (nonatomic ,assign) NSUInteger currentIdx;

@property (nonatomic ,strong) CALayer * indicator;

@end

@implementation DWTitleSectionView
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles handler:(void(^)(NSUInteger idx,NSString * title,UIButton * btn))handler
{
    self = [super initWithFrame:frame];
    if (self) {
        _handler = handler;
        _titles = titles;
        _currentIdx = 0;
        _titleFont = safeFont(nil);
        _titleColor = safeColor(nil);
        _highlightTitleFont = safeFont(nil);
        _highlightTitleColor = [UIColor colorWithRed:25 / 255.0 green:189 / 255.0 blue:234 / 255.0 alpha:1];
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    NSAssert(self.titles.count, @"the titles must contain at least one object");
    NSUInteger count = self.titles.count;
    CGFloat width = self.bounds.size.width / count;
    NSMutableArray * btnArr = [NSMutableArray array];
    for (int i = 0; i < count; i++) {
        UIButton * button = [UIButton buttonWithType:(UIButtonTypeCustom)];
        [button setFrame:CGRectMake(i * width, 0, width, self.bounds.size.height)];
        [button setTitle:self.titles[i] forState:(UIControlStateNormal)];
        button.tag = TagOffset + i;
        [button addTarget:self action:@selector(titleBtnAction:) forControlEvents:(UIControlEventTouchUpInside)];
        [button setTitleColor:_titleColor forState:(UIControlStateNormal)];
        [self addSubview:button];
        [btnArr addObject:button];
        
        if (i < count -1) {
            CALayer * seperatorLine = [CALayer layer];
            seperatorLine.frame = CGRectMake(width * (i + 1) - 0.25, SeperatorLineMargin, 0.5, self.bounds.size.height - SeperatorLineMargin * 2);
            seperatorLine.backgroundColor = SeperatorColor;
            [self.layer addSublayer:seperatorLine];
        }
    }
    self.btnArr = btnArr.copy;
    CALayer * indicator = [CALayer layer];
    indicator.frame = CGRectMake(IndicatorMargin, self.bounds.size.height - IndicatorHeight, width - IndicatorMargin * 2, IndicatorHeight);
    indicator.backgroundColor = IndicatorColor;
    [self.layer addSublayer:indicator];
    self.indicator = indicator;
}

-(void)titleBtnAction:(UIButton *)sender
{
    NSUInteger idx = sender.tag - TagOffset;
    if (idx == _currentIdx) {
        return;
    }
    if (self.handler) {
        self.handler(idx,self.titles[idx],sender);
    }
    _currentIdx = idx;
    [self updateHighligthState];
}

-(void)updateHighligthState
{
    NSUInteger count = self.titles.count;
    CGFloat width = self.bounds.size.width / count;
    self.indicator.position = CGPointMake((_currentIdx + 0.5) * width, self.bounds.size.height - 0.5 * IndicatorHeight);
    self.highlightTitleColor = self.highlightTitleColor;
    self.titleColor = self.titleColor;
    self.highlightTitleFont = self.highlightTitleFont;
    self.titleFont = self.titleFont;
}

-(void)setTitleColor:(UIColor *)titleColor
{
    _titleColor = titleColor;
    [self.btnArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != _currentIdx || !self.highlightTitleColor) {
            [obj setTitleColor:safeColor(titleColor) forState:(UIControlStateNormal)];
        }
    }];
}

-(void)setHighlightTitleColor:(UIColor *)highlightTitleColor
{
    _highlightTitleColor = highlightTitleColor;
    UIButton * btn = self.btnArr[_currentIdx];
    [btn setTitleColor:safeColor(highlightTitleColor) forState:(UIControlStateNormal)];
}

-(void)setTitleFont:(UIFont *)titleFont
{
    _titleFont = titleFont;
    [self.btnArr enumerateObjectsUsingBlock:^(UIButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (idx != _currentIdx || !self.highlightTitleFont) {
            obj.titleLabel.font = safeFont(titleFont);
        }
    }];
}

-(void)setHighlightTitleFont:(UIFont *)highlightTitleFont
{
    _highlightTitleFont = highlightTitleFont;
    UIButton * btn = self.btnArr[_currentIdx];
    btn.titleLabel.font = safeFont(highlightTitleFont);
}

static inline UIColor * safeColor(UIColor * color){
    return color?color:[UIColor blackColor];
};

static inline UIFont * safeFont(UIFont * font){
    return font?font:[UIButton buttonWithType:(UIButtonTypeCustom)].titleLabel.font;
};
@end
