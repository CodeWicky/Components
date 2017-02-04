//
//  DWCountdownButton.h
//  DWCountdownButton
//
//  Created by Wicky on 2017/2/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

/**
 倒计时按钮
 
 自动处理倒计时状态的按钮
 */

#import <UIKit/UIKit.h>

@interface DWCountdownButton : UIButton

///倒计时标题样式
/**
 eg.    若想倒计时标题形如： 剩余15.37秒,请赋值    @"剩余%.2f秒"
 
 注：保留整数请使用  %.0f
 */
@property (nonatomic ,copy) NSString * titleFormatter;

///计时结束标题
/**
 计时结束后自动改变为该标题
 
 若为空，则返回计时前标题。
 若计时前未设置标题，则返回默认值   重新计时
 */
@property (nonatomic ,copy) NSString * timeOutTitle;

///计时（开始/结束）后是否（禁用/恢复）按钮
/**
 默认开启
 */
@property (nonatomic ,assign) BOOL autoDisable;

///是否保留绝对时间
/**
 即重新生成按钮后，是否继续上次的计时。默认关闭
 
 eg.发送验证码，60秒间隔，计时至35秒时退出页面，过10秒后进入页面，此时按钮显示25秒
 
 注：需配合absoluteTimeKey使用，按照key返回对应的缓存的时间
 */
@property (nonatomic ,assign) BOOL useAbsoluteTime;

///读取绝对时间的key
/**
 默认值    defaultKey
 */
@property (nonatomic ,copy) NSString * absoluteTimeKey;

///倒计时结束回调
@property (nonatomic ,copy) void (^timeOutBlock)(DWCountdownButton * btn);

///实例化方法
+(instancetype)buttonWithType:(UIButtonType)buttonType timeLimit:(CGFloat)timeLimit timeInterval:(CGFloat)timeInterval;

///开始计时
-(void)startCountdown;

///暂停
-(void)suspendCountdown;

///恢复
-(void)resumeCountdown;

///停止
-(void)stopCountdown;
@end
