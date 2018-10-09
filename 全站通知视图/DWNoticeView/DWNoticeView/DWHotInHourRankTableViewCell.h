//
//  DWHotInHourRankTableViewCell.h
//  DWNoticeView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

///小时榜单的轮播cell
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

///小时榜单数据模型
@interface DWHotInHourRankModel : NSObject

/**
 cell对应展示文字
 */
@property (nonatomic ,copy) NSString * text;

/**
 以下属性均为辅助计算属性，无需关心
 */
@property (nonatomic ,assign) NSUInteger index;
@property (nonatomic ,assign) NSTimeInterval timeInterval;
@property (nonatomic ,assign) CGFloat delta;
@property (nonatomic ,assign) CGFloat total;
@property (nonatomic ,assign) CGFloat containerW;

@end

///小时榜单展示cell
@interface DWHotInHourRankTableViewCell : UITableViewCell

@property (nonatomic ,strong) DWHotInHourRankModel * model;

@property (nonatomic ,copy) void(^bannerDidClickCallback)(DWHotInHourRankModel * model);

///配置指定模型应该展示的时间，赋值模型或需要用到时间之前务必调用（如果计算过时间不会反复计算，可以无脑调用）
+(void)configModelWithCellWidth:(CGFloat)width timeInterval:(DWHotInHourRankModel *)model;

///按需配置动画
-(void)handleAnimation;

@end

NS_ASSUME_NONNULL_END
