//
//  DWNewsView.h
//  DWNewsView
//
//  Created by Wicky on 2016/11/30.
//  Copyright © 2016年 Wicky. All rights reserved.
//


/**
 DWNewsView
 新闻通告展示视图
 
 version 1.0.0
 自动展示新闻通告，提供字体、颜色设置。
 长通告自动动画展示
 */
#import <UIKit/UIKit.h>

@interface DWNewsView : UIView

///当前通告组
@property (nonatomic ,strong) NSArray<NSString *> * news;

///字体
@property (nonatomic ,strong) UIFont * font;

///字体颜色
@property (nonatomic ,strong) UIColor * textColor;

///通告滚动速度
/**
 每秒移动像素数，推荐值30。
 */
@property (nonatomic ,assign) CGFloat speed;

/**
 初始化方法
 
 frame:尺寸
 news:通告组
 timeInterval:通告切换时间间隔
 speed:通告滚动速度
 handler:点击回调
 */
-(instancetype)initWithFrame:(CGRect)frame
                        news:(NSArray<NSString *> *)news
                timeInterval:(NSTimeInterval)timeInterval
                       speed:(CGFloat)speed
                  clickBlock:(void(^)(NSInteger index,NSString * news))handler;

///销毁当前控件
/**
 主要用与移除控件中定时器，避免循环引用，销毁控件时请调用此方法
 辅助作用，从当前父视图中移除自身
 */
-(void)invalidateNewsView;
@end
