
//
//  ProgressButton.m
//  ProgressButton
//
//  Created by Wicky on 16/7/17.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWProgressButton.h"

@interface DWProgressButton ()

@property (strong ,nonatomic) UILabel * tintLabel;

@end

@implementation DWProgressButton

+(instancetype)buttonWithType:(UIButtonType)buttonType
{
    buttonType = UIButtonTypeSystem;
    return [super buttonWithType:buttonType];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.tintLabel = [[UILabel alloc] initWithFrame:self.bounds];
        self.tintLabel.textAlignment = NSTextAlignmentCenter;
        [self insertSubview:self.tintLabel atIndex:0];
    }
    return self;
}

-(void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    if (!self.completeTextColor) {
        self.completeTextColor = backgroundColor;
    }
}

-(void)setTitleColor:(UIColor *)color forState:(UIControlState)state
{
    [super setTitleColor:color forState:state];
    if (state == UIControlStateNormal && !self.completeBackgroundColor) {
        self.completeBackgroundColor = color;
    }
}

-(void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        self.tintLabel.textColor = [self.completeTextColor colorWithAlphaComponent:0.2];
    }
    else
    {
        self.tintLabel.textColor = self.completeTextColor;
    }
}

-(void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.tintLabel.textColor = [self.completeTextColor colorWithAlphaComponent:0.2];
    [UIView animateWithDuration:0.47 animations:^{
        self.tintLabel.textColor = self.completeTextColor;
    }];
    
    self.tintLabel.text = self.titleLabel.text;
    self.tintLabel.backgroundColor = self.completeBackgroundColor;
    self.tintLabel.frame = self.bounds;
    [self bringSubviewToFront:self.tintLabel];
    self.tintLabel.font = self.titleLabel.font;
    
    UIBezierPath * line = [UIBezierPath bezierPath];
    [line moveToPoint:CGPointMake(0, self.tintLabel.bounds.size.height / 2.0)];
    [line addLineToPoint:CGPointMake(self.tintLabel.bounds.size.width, self.tintLabel.bounds.size.height / 2.0)];
    
    CAShapeLayer * mask = (CAShapeLayer *)self.tintLabel.layer.mask;
    if (!mask) {
        mask = [CAShapeLayer layer];
        mask.strokeColor = [UIColor blackColor].CGColor;
        self.tintLabel.layer.mask = mask;
    }
    mask.bounds = self.tintLabel.bounds;
    mask.position = CGPointMake(self.tintLabel.bounds.size.width / 2.0, self.tintLabel.bounds.size.height / 2.0);
    mask.path = line.CGPath;
    mask.lineWidth = self.tintLabel.bounds.size.height;
    mask.strokeEnd = self.progress;
}

-(void)setProgress:(CGFloat)progress
{
    if (progress > 1) {
        progress = 1;
    }
    if (progress < 0) {
        progress = 0;
    }
    _progress = progress;
    [self setNeedsDisplay];
}

@end
