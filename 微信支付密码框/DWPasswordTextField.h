//
//  DWPasswordTextField.h
//  DWPWDTextField
//
//  Created by Wicky on 16/11/24.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 密码输入textField
 
 支持文本输入自动替换密文形式
 支持文本输入完成回调
 支持密文切换
 支持密码位数限制
 支持自动布局
 屏蔽长按菜单
 
 */

@interface DWPasswordTextField : UITextField

///密码位数
@property (nonatomic ,assign) NSInteger pwdCount;

///输入完成回调
@property (nonatomic ,copy) void (^inputFinishBlock)(NSString *);

///初始化方法
-(instancetype)initWithFrame:(CGRect)frame pwdCount:(NSInteger)count;

@end
