//
//  DWPasswordTextField.m
//  DWPWDTextField
//
//  Created by Wicky on 16/11/24.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import "DWPasswordTextField.h"

///支持密文显示的label
@interface PWDLB : UILabel

@property (nonatomic ,assign) BOOL secureTextEntry;

@end

@implementation PWDLB

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.secureTextEntry = YES;
        self.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(void)setSecureTextEntry:(BOOL)secureTextEntry
{
    _secureTextEntry = secureTextEntry;
    [self setNeedsDisplay];///重绘
}

-(void)drawRect:(CGRect)rect
{
    if (self.secureTextEntry) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextSetRGBStrokeColor(context, 0, 0, 0, 1);
        CGContextSetLineWidth(context, 5.0);
        CGContextAddEllipseInRect(context, CGRectMake(rect.size.width / 2.0 - 2.5, rect.size.height / 2.0 - 2.5, 5, 5));
        CGContextStrokePath(context);
    }
    else
    {
        [super drawRect:rect];
    }
}

@end

@interface DWPasswordTextField ()<UITextFieldDelegate>

@property (nonatomic ,strong) NSMutableArray * lbArr;

@end

@implementation DWPasswordTextField

-(instancetype)initWithFrame:(CGRect)frame pwdCount:(NSInteger)count
{
    self = [super initWithFrame:frame];
    if (self) {
        self.pwdCount = count;
        self.lbArr = [NSMutableArray array];
        CGFloat width = frame.size.width / self.pwdCount;
        CGFloat height = frame.size.height;
        self.delegate = self;
        self.font = [UIFont systemFontOfSize:0];///防止双击选中出现选中范围
        self.keyboardType = UIKeyboardTypeNumberPad;
        self.tintColor = [UIColor clearColor];///取消光标
        self.layer.borderWidth = 0.5;
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        for (int i = 0; i < self.pwdCount; i ++) {///添加密文label
            PWDLB * label = [[PWDLB alloc] initWithFrame:CGRectMake(i * width, 0, width, height)];
            label.tag = 10000 + i;
            label.hidden = YES;
            [self addSubview:label];
            [self.lbArr addObject:label];
        }
        
        [self handleBackgroundView];///处理分割线
    }
    return self;
}

-(void)handleBackgroundView///背景分割线处理
{
    CGRect frame = self.bounds;
    CGFloat width = frame.size.width / self.pwdCount;
    CGFloat height = frame.size.height;
    
    UIView * back = [self viewWithTag:99999];
    if (back != nil) {
        [back removeFromSuperview];
    }
    
    back = [[UIView alloc] initWithFrame:frame];
    back.userInteractionEnabled = NO;
    back.tag = 99999;
    back.backgroundColor = [UIColor clearColor];
    [self insertSubview:back atIndex:0];
    
    for (int i = 1; i < self.pwdCount; i++) {
        CALayer * layer = [CALayer layer];
        layer.backgroundColor = [UIColor lightGrayColor].CGColor;
        layer.bounds = CGRectMake(0, 0, 0.5, height);
        layer.position = CGPointMake(i * width, height / 2.0);
        [back.layer addSublayer:layer];
    }
}

-(void)setSecureTextEntry:(BOOL)secureTextEntry///密文形式切换
{
    [super setSecureTextEntry:secureTextEntry];
    for (PWDLB * view in self.lbArr) {
        view.secureTextEntry = secureTextEntry;
    }
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    CGRect frame = self.bounds;
    CGFloat width = frame.size.width / self.pwdCount;
    CGFloat height = frame.size.height;
    for (int i = 0; i < self.pwdCount; i++) {///自动布局label
        PWDLB * label = self.lbArr[i];
        label.frame = CGRectMake(i * width, 0, width, height);
    }
    [self handleBackgroundView];
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * des = [self.text stringByReplacingCharactersInRange:range withString:string];
    if (des.length > self.pwdCount) {///长度过滤
        return NO;
    }
    
    self.text = des;
    
    if (self.text.length == self.pwdCount) {
        if (self.inputFinishBlock) {
            self.inputFinishBlock(self.text);
        }
    }
    return NO;
}

-(void)setText:(NSString *)text
{
    if (text.length <= self.pwdCount) {
        ///自动进行密文处理
        [super setText:text];
        [self handleLb];
    }
}

-(void)handleLb
{
    for (int i = 0; i < self.pwdCount; i ++) {///密文处理
        PWDLB * lb = self.lbArr[i];
        if (i < self.text.length) {
            lb.text = [self.text substringWithRange:NSMakeRange(i, 1)];
            lb.hidden = NO;
        }
        else
        {
            lb.text = @"";
            lb.hidden = YES;
        }
    }
}


///取消长按菜单
-(BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    return NO;
}
@end
