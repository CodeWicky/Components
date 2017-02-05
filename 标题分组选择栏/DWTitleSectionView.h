//
//  DWTitleSectionView.h
//  DWCountdownButton
//
//  Created by Wicky on 2017/2/5.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>
#define DefaultHighlightColor [UIColor colorWithRed:25 / 255.0 green:189 / 255.0 blue:234 / 255.0 alpha:1]
@interface DWTitleSectionView : UIView

///标题数组
@property (nonatomic ,strong) NSArray * titles;

///标题颜色
@property (nonatomic ,strong) UIColor * titleColor;

///标题高亮颜色
@property (nonatomic ,strong) UIColor * highlightTitleColor;

///标题字体
@property (nonatomic ,strong) UIFont * titleFont;

///高亮标题字体
@property (nonatomic ,strong) UIFont * highlightTitleFont;

///实例化方法
-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titles handler:(void(^)(NSUInteger idx,NSString * title,UIButton * btn))handler;

@end
