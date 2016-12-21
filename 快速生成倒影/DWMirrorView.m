//
//  DWMirrorView.m
//  Rec
//
//  Created by Wicky on 2016/12/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWMirrorView.h"

@interface DWMirrorView ()

///倒影淡去遮罩层
@property (nonatomic ,strong) CAGradientLayer * maskLayer;

///静态倒影图片展示view
@property (nonatomic ,strong) UIImageView * mirrorImageView;

@end

@implementation DWMirrorView

#pragma mark ---tool method---
-(void)handleMirrorDistant:(CGFloat)distant
{
    CAReplicatorLayer * layer = (CAReplicatorLayer *)self.layer;
    CATransform3D transform = CATransform3DIdentity;
    transform = CATransform3DTranslate(transform, 0, distant + self.bounds.size.height, 0);
    transform = CATransform3DScale(transform, 1, -1, 0);
    layer.instanceTransform = transform;
}

-(NSArray *)getMaskLayerLocations
{
    CGFloat height = self.bounds.size.height * 2 + self.mirrorDistant;
    CGFloat mirrowScale = self.bounds.size.height * (1 + self.mirrorScale) + self.mirrorDistant;
    return @[@0,@((self.bounds.size.height + self.mirrorDistant) / height),@(mirrowScale / height)];
}

-(CGFloat)safeValueBetween0And1:(CGFloat)value
{
    if (value > 1) {
        value = 1;
    } else if (value < 0) {
        value = 0;
    }
    return value;
}

-(void)valueInit
{
    self.mirrorDistant = 0;
    self.mirrorScale = 0.5;
    self.mirrored = YES;
    self.dynamic = YES;
    self.mirrorAlpha = 0.5;
}

#pragma mark ---override---

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self valueInit];
    }
    return self;
}

-(void)awakeFromNib
{
    [super awakeFromNib];
    [self valueInit];
}

+(Class)layerClass
{
    return [CAReplicatorLayer class];
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    CAReplicatorLayer * layer = (CAReplicatorLayer *)self.layer;
    if (self.mirrored) {
        if (self.dynamic) {
            [self.mirrorImageView removeFromSuperview];
            self.mirrorImageView = nil;
            layer.instanceCount = 2;
            if (CATransform3DEqualToTransform(layer.instanceTransform, CATransform3DIdentity)) {
                [self handleMirrorDistant:self.mirrorDistant];
            }
        }
        else
        {
            layer.instanceCount = 1;
            CGSize size = CGSizeMake(self.bounds.size.width, self.bounds.size.height * self.mirrorScale);
            if (size.height > 0.0f && size.width > 0.0f)
            {
                UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
                CGContextRef context = UIGraphicsGetCurrentContext();
                CGContextScaleCTM(context, 1.0f, -1.0f);
                CGContextTranslateCTM(context, 0.0f, -self.bounds.size.height);
                [self.layer renderInContext:context];
                self.mirrorImageView.image = UIGraphicsGetImageFromCurrentImageContext();
                UIGraphicsEndImageContext();
            }
            self.mirrorImageView.alpha = self.mirrorAlpha;
            self.mirrorImageView.frame = CGRectMake(0, self.bounds.size.height + self.mirrorDistant, size.width, size.height);
        }
        self.layer.mask = self.maskLayer;
    }
    else
    {
        layer.instanceCount = 1;
        [self.mirrorImageView removeFromSuperview];
        self.mirrorImageView = nil;
        self.layer.mask = nil;
    }
    
}

#pragma mark ---setter/getter---

-(void)setMirrored:(BOOL)mirrored
{
    _mirrored = mirrored;
    [self setNeedsDisplay];
}

-(void)setDynamic:(BOOL)dynamic
{
    _dynamic = dynamic;
    [self setNeedsDisplay];
}

-(void)setMirrorAlpha:(CGFloat)mirrorAlpha
{
    _mirrorAlpha = [self safeValueBetween0And1:mirrorAlpha];
    if (self.mirrored) {
        if (self.dynamic) {
            CAReplicatorLayer * layer = (CAReplicatorLayer *)self.layer;
            layer.instanceAlphaOffset = self.mirrorAlpha - 1;
        }
        else
        {
            [self setNeedsDisplay];
        }
    }
    
}

-(void)setMirrorScale:(CGFloat)mirrorScale
{
    _mirrorScale = [self safeValueBetween0And1:mirrorScale];
    if (self.mirrored) {
        self.maskLayer.locations = [self getMaskLayerLocations];
        if (!self.dynamic) {
            [self setNeedsDisplay];
        }
    }
}

-(void)setMirrorDistant:(CGFloat)mirrorDistant
{
    _mirrorDistant = mirrorDistant;
    if (self.mirrored) {
        self.maskLayer = nil;
        [self handleMirrorDistant:mirrorDistant];
        [self setNeedsDisplay];
    }
}

-(CAGradientLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAGradientLayer layer];
        _maskLayer.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height * 2 + self.mirrorDistant);
        _maskLayer.startPoint = CGPointMake(0, 0);
        _maskLayer.endPoint = CGPointMake(0, 1);
        _maskLayer.locations = [self getMaskLayerLocations];
        _maskLayer.colors = @[(id)[UIColor blackColor].CGColor,(id)[UIColor blackColor].CGColor,(id)[UIColor clearColor].CGColor];
    }
    return _maskLayer;
}

-(UIImageView *)mirrorImageView
{
    if (!_mirrorImageView) {
        _mirrorImageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _mirrorImageView.contentMode = UIViewContentModeScaleToFill;
        _mirrorImageView.userInteractionEnabled = NO;
        [self addSubview:_mirrorImageView];
    }
    return _mirrorImageView;
}
@end
