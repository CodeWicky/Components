//
//  DWMirrorView.h
//  Rec
//
//  Created by Wicky on 2016/12/20.
//  Copyright © 2016年 Wicky. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 DWMirrorView
 
 快速生成视图倒影的控件
 
 注：DWMirrorView只作为容器存在，将需要倒影的视图作为子视图加入至DWMirrorView中即可。
 倒影不会响应DWMirrorView的圆角、背景色、阴影的一系列属性，倒影会响应DWMirrorView的所有子视图属性。
 
 version 1.0.0
 实现倒影控制
 实现动静态控制
 自定义倒影相关参数
 */

@interface DWMirrorView : UIView

///是否具有镜像效果
@property (nonatomic ,assign) BOOL mirrored;

///镜像是否具有动态效果
@property (nonatomic ,assign) BOOL dynamic;

///镜像透明度,支持动画效果
@property (nonatomic ,assign) CGFloat mirrorAlpha;

///镜像与本体的距离
@property (nonatomic ,assign) CGFloat mirrorDistant;

///镜像淡去的比例,支持动画效果
@property (nonatomic ,assign) CGFloat mirrorScale;

@end
