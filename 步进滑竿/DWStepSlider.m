//
//  DWStepSlider.m
//  a
//
//  Created by Wicky on 2017/3/31.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWStepSlider.h"
#import "UIBezierPath+DWPathUtils.h"

@interface DWStepSlider ()
{
    CAShapeLayer * _trackUpLayer;
    CAShapeLayer * _trackDownLayer;
}
@property (nonatomic ,strong) CALayer * trackBgLayer;

@property (nonatomic ,strong) CALayer * thumbLayer;

@property (nonatomic ,strong) CAShapeLayer * trackUpLayer;

@property (nonatomic ,strong) CAShapeLayer * trackDownLayer;

@property (nonatomic ,assign) BOOL clickOnThumb;

@end


@implementation DWStepSlider
@dynamic trackBgLayer,thumbLayer,trackUpLayer,trackDownLayer,value,minimumValue,maximumValue,trackHeight,thumbImage,minTrackImage,maxTrackImage,trackBgImage,minTrackColor,maxTrackColor;
#pragma mark --- interface Method ---
-(instancetype)initWithFrame:(CGRect)frame {
    NSAssert(NO, @"Use method -initWithFrame:stepNodes: to initialize a instance please.");
    return nil;
}

-(instancetype)initWithFrame:(CGRect)frame stepNodes:(NSArray *)nodes {
    NSAssert(nodes.count > 1, @"Illegal nodes!Nodes at least contain two Nodes.");
    if (self = [super initWithFrame:frame]) {
        _nodes = [nodes copy];
        [self customsizeDefalutValue];
        [self customsizeBaseUI];
    }
    return self;
}

-(void)customsizeDefalutValue {
    CGFloat height = self.frame.size.height;
    ///default value
    self.trackHeight = height;
    self.thumbMargin = height / 2;
    self.thumbSize = CGSizeMake(0.7 * height, 0.7 * height);
    
    ///default color
    self.trackBgLayer.backgroundColor = [UIColor colorWithRed:0.843 green:0.843 blue:0.843 alpha:1].CGColor;
    [self setMaxTrackColor:[UIColor colorWithRed:0.717 green:0.717 blue:0.717 alpha:1]];
    [self setMinTrackColor:[UIColor colorWithRed:0 green:0.48 blue:1 alpha:1]];
}

-(void)customsizeBaseUI {
    ///bgLayerMask
    CGRect bgBounds = self.trackBgLayer.bounds;
    UIBezierPath * bgPath = PathWithParams(bgBounds, _nodes.count);
    self.trackBgLayer.mask = MaskLayer(bgBounds, bgPath);
    
    ///valueTrack Path
    CGFloat offset = (self.trackHeight - self.thumbSize.height) / 2;
    CGRect valueTrackBounds = CGRectInset(bgBounds, offset, offset);
    UIBezierPath * valuePath = PathWithParams(valueTrackBounds, _nodes.count);
    [valuePath dw_TranslatePathWithOffsetX:0 offsetY:offset];
    self.trackUpLayer.path = valuePath.CGPath;
    self.trackDownLayer.path = valuePath.CGPath;
}

#pragma mark --- tracking Method ---
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    location = [self.thumbLayer convertPoint:location fromLayer:self.layer];
    if ([PathWithBounds(self.thumbLayer.bounds, FitCornerRadius(self.thumbLayer, self.thumbCornerRadius)) containsPoint:location]) {
        self.clickOnThumb = YES;
        return YES;
    }
    location = [self.trackBgLayer convertPoint:location fromLayer:self.thumbLayer];
    if ([PathWithBounds(self.trackBgLayer.bounds, FitCornerRadius(self.trackBgLayer, self.trackCornerRadius)) containsPoint:location]) {
        self.clickOnThumb = NO;
        return YES;
    }
    return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    CGPoint location = [touch locationInView:self];
    CGFloat margin = FitMarginForThumb(self.thumbSize, [self thumbMarginForBounds:self.bounds]);
    location.x -= margin;
    CGFloat actualW = CGRectGetWidth([self trackRectForBounds:self.bounds]) - margin * 2;
    if (location.x < 0) {
        location.x = 0;
    } else if (location.x > actualW) {
        location.x = actualW;
    }
    CGFloat percent = location.x / actualW;
    CGFloat value = self.minimumValue + (self.maximumValue - self.minimumValue) * percent;
    if (value == self.value) {
        return YES;
    }
    [self setValue:value updateThumb:NO];
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (self.clickOnThumb) {
        [self updateValueAnimated:NO];
        return YES;
    } else {
        [self setValue:FixValue(value, _nodes.count) updateThumb:NO];
        [self updateValueAnimated:YES];
        return NO;
    }
}

-(void)cancelTrackingWithEvent:(UIEvent *)event {
    if (self.clickOnThumb) {
        self.value = FixValue(self.value, _nodes.count);
        self.clickOnThumb = NO;
    }
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event {
    if (self.clickOnThumb) {
        self.value = FixValue(self.value, _nodes.count);
        self.clickOnThumb = NO;
    }
}

#pragma mark --- inline Method ---
///返回加圆角后的路径
static inline UIBezierPath * PathWithBounds(CGRect bounds,CGFloat radius) {
    return [UIBezierPath bezierPathWithRoundedRect:bounds cornerRadius:radius];
}

///返回适配后的圆角尺寸
static inline CGFloat FitCornerRadius(id image,CGFloat radius) {
    if (![image isKindOfClass:[CALayer class]] && ![image isKindOfClass:[UIView class]]) {
        return 0;
    }
    CGRect frame = [[image valueForKey:@"frame"] CGRectValue];
    return MIN(MIN(frame.size.height,frame.size.width) / 2, radius);
}

///返回适配后的指示器缩进
static inline CGFloat FitMarginForThumb(CGSize thumbSize,CGFloat margin) {
    return ((thumbSize.width > margin * 2) ? thumbSize.width / 2 : margin);
}

static inline CAShapeLayer * MaskLayer(CGRect frame,UIBezierPath * path) {
    CAShapeLayer * layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor blackColor].CGColor;
    layer.frame = path.bounds;
    layer.path = path.CGPath;
    return layer;
}

static inline CGFloat FixValue(CGFloat originValue,NSUInteger nodesCount) {
    CGFloat step = 1.0 / (nodesCount - 1);
    return step * ((int)((originValue + step * 0.5) / step));
}

static inline CGFloat DeltaWidthWithHeightAndRadius(CGFloat height,CGFloat radius) {
    if (radius < height) {
        return 0;
    } else {
        return radius - sqrtf(powf(radius, 2) - powf(height, 2));
    }
}

static inline UIBezierPath * PathWithParams(CGRect rect,NSUInteger countOfPot) {
    if (countOfPot < 2) {
        return nil;
    }
    if (rect.size.height >= rect.size.width) {
        return nil;
    }
    CGFloat valueWidth = (rect.size.width - rect.size.height) / (countOfPot - 1);
    CGFloat stepW = rect.size.height / 2;
    CGFloat trackH = stepW * 0.75;
    CGFloat deltaW = DeltaWidthWithHeightAndRadius(trackH, stepW);
    UIBezierPath * path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(rect.size.height - deltaW, stepW + trackH)];
    for (int i = 0; i < 2 * countOfPot - 2; i++) {
        if (i < countOfPot - 1) {
            CGPoint arcEndP = CGPointMake(stepW + valueWidth * i + stepW - deltaW, stepW - trackH);
            CGPoint lineEndP = CGPointMake(valueWidth * (i + 1) + deltaW, stepW - trackH);
            DrawLineWithThreePoints(path, arcEndP, lineEndP, stepW, (i == 0));
        } else {
            CGPoint arcEndP = CGPointMake(rect.size.width - stepW - (i + 1 - countOfPot) * valueWidth - stepW + deltaW, stepW + trackH);
            CGPoint lineEndP = CGPointMake(rect.size.width - (i + 2 - countOfPot) * valueWidth - deltaW, stepW + trackH);
            DrawLineWithThreePoints(path, arcEndP, lineEndP, stepW, (i == countOfPot - 1));
        }
    }
    
    return path;
}

static inline void DrawLineWithThreePoints(UIBezierPath * path,CGPoint arcEndP,CGPoint lineEndP,CGFloat radius,BOOL moreThanHalf) {
    CGPoint currentP = path.currentPoint;
    [path addArcWithStartPoint:currentP endPoint:arcEndP radius:radius clockwise:YES moreThanHalf:moreThanHalf];
    [path addLineToPoint:lineEndP];
}

#pragma mark --- setter/getter ---

-(CAShapeLayer *)trackUpLayer {
    if (!_trackUpLayer) {
        _trackUpLayer = [CAShapeLayer layer];
        _trackUpLayer.masksToBounds = YES;
        _trackUpLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _trackUpLayer;
}

-(CALayer *)trackDownLayer {
    if (!_trackDownLayer) {
        _trackDownLayer = [CAShapeLayer layer];
        _trackDownLayer.masksToBounds = YES;
        _trackDownLayer.contentsScale = [UIScreen mainScreen].scale;
    }
    return _trackDownLayer;
}

-(void)setMinTrackColor:(UIColor *)minTrackColor {
    if (self.minTrackColor != minTrackColor) {
        [super setMinTrackColor:minTrackColor];
        self.trackUpLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.trackUpLayer.fillColor = minTrackColor.CGColor;
        if (!self.trackBgImage) {
            self.trackUpLayer.hidden = NO;
        }
    }
}

-(void)setMaxTrackColor:(UIColor *)maxTrackColor {
    if (self.maxTrackColor != maxTrackColor) {
        [super setMaxTrackColor:maxTrackColor];
        self.trackDownLayer.backgroundColor = [UIColor clearColor].CGColor;
        self.trackDownLayer.fillColor = maxTrackColor.CGColor;
        if (!self.trackBgImage) {
            self.trackUpLayer.hidden = NO;
        }
    }
}

-(void)setValue:(CGFloat)value {
    [self setValue:value updateThumb:YES];
}

-(void)setMinimumValue:(CGFloat)minimumValue {
    NSAssert(NO, @"In this Slider you needn't set the MinimumValue or MaximumValue!");
}

-(void)setMaximumValue:(CGFloat)maximumValue {
    NSAssert(NO, @"In this Slider you needn't set the MinimumValue or MaximumValue!");
}

-(id)currentNode {
    CGFloat step = 1.0 / (_nodes.count - 1);
    return self.nodes[((int)((self.value + step * 0.5) / step))];
}
@end
