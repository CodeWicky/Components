//
//  DWWaterFallLayout.h
//  testCol
//
//  Created by Wicky on 2018/11/29.
//  Copyright © 2018 Wicky. All rights reserved.
//

/*
 DWWaterFallLayout
 瀑布流布局
 
 提供方向、列数等可控参数。
 1.使用时请保证layout中items与colV数据源个数相同
 2.当前只考虑colV组数为0情况
 3.items中为遵循DWWaterFallLayoutItemProtocol的实例。遵循协议后应自行使用@synthesize originSize;合成setter/getter方法。items中实例务必赋值originSize为项目原始尺寸或者原始比例
 
 */

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWWaterFallLayoutItemProtocol <NSObject>

@property (nonatomic ,assign) CGSize originSize;

@end

typedef NS_ENUM(NSUInteger, DWWaterFallLayoutDirection) {
    DWWaterFallLayoutDirectionVertical,
    DWWaterFallLayoutDirectionHorizontal,
};


///瀑布流滑动方向为列方向，滑动方向垂直方向即为行方向
@interface DWWaterFallLayout : UICollectionViewLayout
///瀑布流方向
@property (nonatomic ,assign) DWWaterFallLayoutDirection direction;
///瀑布流列数(默认值3)
@property (nonatomic ,assign) NSUInteger columnCount;
///行间距(默认值10)
@property (nonatomic ,assign) CGFloat lineSpacing;
///列间距(默认值10)
@property (nonatomic ,assign) CGFloat interitemSpacing;
///整体四周内边距
@property (nonatomic ,assign) UIEdgeInsets edgeInsets;
///描述每一项原始尺寸的数组
@property (nonatomic ,assign) NSMutableArray <id<DWWaterFallLayoutItemProtocol>>* items;

@end



NS_ASSUME_NONNULL_END
