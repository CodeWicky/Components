//
//  ProgressButton.h
//  ProgressButton
//
//  Created by Wicky on 16/7/17.
//  Copyright © 2016年 Wicky. All rights reserved.
//

/**
 DWProgressButton
 可以显示进度的反色按钮
 
 支持进度显示
 支持自定义完成进度背景颜色
 支持自定义完成进度文字颜色
 */

#import <UIKit/UIKit.h>

@interface DWProgressButton : UIButton

///当前进度
@property (assign ,nonatomic) CGFloat progress;

///完成进度的背景颜色，默认值为titleColor
@property (nonatomic ,strong) UIColor * completeBackgroundColor;

///完成进度的文字颜色，默认值为backgroundColor
@property (nonatomic ,strong) UIColor * completeTextColor;
@end
