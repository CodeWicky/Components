//
//  DWNoticeView.h
//  DWNoticeView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

///可替换cell、可定制轮播时长的上下轮播视图
#import <UIKit/UIKit.h>

@class DWNoticeView;
@protocol DWNoticeViewDelegate

@optional
/**
 返回当前角标cell展示时长
 
 @param banner 当前banner视图
 @param index 当前展示的角标
 @return 当前展示的cell将要展示的时长
 
 @disc 若实现代理则以代理为准，若未实现则以初始化方法中的时间间隔为准
 */
-(NSTimeInterval)banner:(DWNoticeView *)banner timeIntervalForCellAtIndex:(NSUInteger)index;


/**
 banner视图被点击
 
 @param banner 当前banner视图
 @param index 被点击的角标
 */
-(void)banner:(DWNoticeView *)banner didSelectRowAtIndex:(NSUInteger)index;


/**
 banner开始展示cell
 
 @param banner 当前banner视图
 @param cell 当前展示cell
 @param index 当前展示的角标
 */
-(void)banner:(DWNoticeView *)banner didDisplayCell:(UITableViewCell *)cell atIndex:(NSUInteger)index;

@required
/**
 返回当前banner对应角标的cell
 
 @param banner 当前banner
 @param index 指定角标
 @param flag 内部维护参数
 @return 对应位置的cell
 */
-(__kindof UITableViewCell *)banner:(DWNoticeView *)banner cellForRowAtIndex:(NSUInteger)index flag:(BOOL)flag;


/**
 返回当前banner视图总cell个数
 
 @param banner 当前banner视图
 @return 总cell个数
 */
-(NSUInteger)numberOfRowsForBanner:(DWNoticeView *)banner;

@end


@interface DWNoticeView : UIView

/**
 当前视图的代理
 */
@property (nonatomic ,weak) id<DWNoticeViewDelegate> delegate;


/**
 当前banner是否正在轮播
 */
@property (nonatomic ,assign ,readonly ,getter=isPlaying) BOOL playing;

NS_ASSUME_NONNULL_BEGIN


/**
 实例化方法
 
 @param frame 尺寸
 @param timeInterval 轮播时间间隔
 @return 实例
 
 @disc 若实现了 -banner:timeIntervalForCell:atIndex: 代理则以代理为准
 */
-(instancetype)initWithFrame:(CGRect)frame timeInterval:(NSTimeInterval)timeInterval;


/**
 注册使用的cell
 
 @param cellClass cell类型
 @param cellID 重用ID
 
 @disc 内部封装tableView，此处用法均针对内部tableView操作
 */
-(void)registerClass:(nullable Class)cellClass forCellReuseIdentifier:(NSString *)cellID;


/**
 获取重用的cell
 
 @param cellID 重用ID
 @param index 指定角标
 @param flag 内部维护参数
 @return 重用的cell
 
 @disc 内部封装tableView，此处用法均针对内部tableView操作
 */
-(UITableViewCell *)dequeueCellForID:(NSString *)cellID atIndex:(NSUInteger)index flag:(BOOL)flag;


/**
 获取指定角标对应的cell
 
 @param index 指定角标
 @return 指定cell
 
 @disc 内部封装tableView，此处用法均针对内部tableView操作
 */
-(__kindof UITableViewCell *)cellForRowAtIndex:(NSUInteger)index;


/**
 开始轮播
 */
-(void)play;


/**
 停止轮播
 */
-(void)stop;


/**
 刷新数据
 */
-(void)reloadData;

NS_ASSUME_NONNULL_END
@end
