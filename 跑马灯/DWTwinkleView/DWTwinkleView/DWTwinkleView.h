//
//  DWTwinkleView.h
//  DWTwinkleView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol DWTwinkleItemProtocol<NSObject>

@required
+(instancetype)itemWithIndex:(NSUInteger)index;
@optional
-(void)updateTwinkleWithInfo:(NSDictionary *)userInfo;
-(void)resetItemStatusOnReLayout;

@end

@interface DWTwinkleConfiguration : NSObject

@property (nonatomic ,assign) CGSize itemSize;

@property (nonatomic ,assign) CGFloat spacing;

@property (nonatomic ,assign) CGFloat margin;

@property (nonatomic ,assign) Class itemClass;

@end

@interface DWTwinkleView : UIView

@property (nonatomic ,assign ,readonly) BOOL twinkling;

-(instancetype)initWithFrame:(CGRect)frame configuration:(DWTwinkleConfiguration *)config;

-(void)resizeTwinkleWithSize:(CGSize)size;

-(void)startTwinkleWithInterval:(NSTimeInterval)time;

-(void)endTwinkle;

@end

NS_ASSUME_NONNULL_END
