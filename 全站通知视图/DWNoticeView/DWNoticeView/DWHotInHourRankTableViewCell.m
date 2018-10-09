//
//  DWHotInHourRankTableViewCell.m
//  DWNoticeView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWHotInHourRankTableViewCell.h"
#import "DWNoticeView.h"

#define kFont ([UIFont boldSystemFontOfSize:13])
#define kSpeedScale (30.0)
#define kPadding (18 + 4 + 8)

#define RGBACOLOR(r,g,b,a)  [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

@implementation DWHotInHourRankModel

-(void)setText:(NSString *)text {
    if ([self.text isEqualToString:text]) {
        return;
    }
    _text = text;
    self.timeInterval = 0;
}

@end

@interface DWHotInHourRankTableViewCell ()

@property (nonatomic ,strong) UIView * containerView;

@property (nonatomic ,strong) UIView * animationContainer;

@property (nonatomic ,strong) UIImageView * arrowView;

@property (nonatomic ,strong) UILabel * textLb;

@end

@implementation DWHotInHourRankTableViewCell

#pragma mark --- interface method ---
+(void)configModelWithCellWidth:(CGFloat)width timeInterval:(DWHotInHourRankModel *)model {
    if (model.timeInterval == 0) {
        CGFloat time = 1 + [self calculateTimeWithCellWidth:width model:model];
        time = time > 5 ? time : 5;
        model.timeInterval = time;
    }
}

-(void)handleAnimation {
    if (self.model.delta > 0) {
        CAAnimationGroup * aniG = [CAAnimationGroup animation];
        aniG.duration = self.model.timeInterval + 1;
        aniG.fillMode = kCAFillModeForwards;
        aniG.removedOnCompletion = YES;
        CABasicAnimation * aniP = [CABasicAnimation animationWithKeyPath:@"position"];
        CGPoint fromP = self.animationContainer.layer.position;
        CGPoint toP = CGPointMake(fromP.x - self.model.delta, fromP.y);
        aniP.beginTime = 0.5;
        aniP.duration = self.model.timeInterval - 1;
        aniP.fromValue = [NSValue valueWithCGPoint:fromP];
        aniP.toValue = [NSValue valueWithCGPoint:toP];
        aniP.fillMode = kCAFillModeForwards;
        aniP.removedOnCompletion = NO;
        aniG.animations = @[aniP];
        
        [self.animationContainer.layer addAnimation:aniG forKey:@"pAni"];
    }
}

#pragma mark --- tool method ---
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setupUI];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setupUI];
}

-(void)setupUI {
    [self.contentView addSubview:self.containerView];
    [self.animationContainer addSubview:self.textLb];
    [self.animationContainer addSubview:self.arrowView];
    self.containerView.backgroundColor = RGBACOLOR(255, 68, 191,0.7);
}

+(CGFloat)calculateLbWidthWithText:(NSString *)text {
    return ceil([text sizeWithAttributes:@{NSFontAttributeName:kFont}].width);
}

+(NSTimeInterval)calculateTimeWithCellWidth:(CGFloat)width model:(DWHotInHourRankModel *)model {
    CGFloat textW = [self calculateLbWidthWithText:model.text];
    CGFloat total = kPadding + textW;
    CGFloat delta = total - width;
    model.total = total;
    if (delta < 0) {
        model.delta = 0;
        model.containerW = total;
    } else {
        model.delta = delta;
        model.containerW = width;
    }
    return delta / kSpeedScale;
}

-(void)handleViewFrame {
    if (self.model) {
        self.containerView.frame = CGRectMake(0, 0, self.model.containerW, self.bounds.size.height);
        self.containerView.layer.cornerRadius = self.containerView.frame.size.height / 2;
        self.animationContainer.frame = CGRectMake(0, 0, self.model.total, self.bounds.size.height);
        self.textLb.frame = CGRectMake(9, 0, self.model.total - kPadding, self.bounds.size.height);
        self.arrowView.frame = CGRectMake(self.model.total - 9 - 8, 5, 8, 8);
    }
}

#pragma mark --- btn action ---
-(void)containerAction:(UITapGestureRecognizer *)sender {
    if (self.bannerDidClickCallback) {
        self.bannerDidClickCallback(self.model);
    }
}

#pragma mark --- override ---
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
}

-(void)setFrame:(CGRect)frame {
    [super setFrame:frame];
    [self handleViewFrame];
}

-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    BOOL inContent = [self.contentView pointInside:point withEvent:event];
    if (!inContent) {
        return nil;
    }
    CGPoint convertPoint = [self.containerView convertPoint:point fromView:self.contentView];
    BOOL inContainer = [self.containerView pointInside:convertPoint withEvent:event];
    if (!inContainer) {
        return nil;
    }
    return self.containerView;
}

#pragma mark --- setter/getter ---
-(void)setModel:(DWHotInHourRankModel *)model {
    _model = model;
    [self handleViewFrame];
    self.textLb.text = model.text;
}

-(UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:self.bounds];
        _containerView.layer.cornerRadius = self.bounds.size.height / 2.0;
        _containerView.clipsToBounds = YES;
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(containerAction:)];
        [_containerView addGestureRecognizer:tap];
        [_containerView addSubview:self.animationContainer];
    }
    return _containerView;
}

-(UIView *)animationContainer {
    if (!_animationContainer) {
        _animationContainer = [[UIView alloc] initWithFrame:self.bounds];
    }
    return _animationContainer;
}

-(UILabel *)textLb {
    if (!_textLb) {
        _textLb = [[UILabel alloc] init];
        _textLb.textColor = [UIColor whiteColor];
        _textLb.font = kFont;
    }
    return _textLb;
}

-(UIImageView *)arrowView {
    if (!_arrowView) {
        _arrowView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
        _arrowView.image = [UIImage imageNamed:@"arrow"];
    }
    return _arrowView;
}

@end

