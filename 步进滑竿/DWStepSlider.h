//
//  DWStepSlider.h
//  a
//
//  Created by Wicky on 2017/3/31.
//  Copyright © 2017年 Wicky. All rights reserved.
//


/**
 DWStepSlider
 步进Slider，分段式Slider
 请手动引入DWSlider及UIBezierPath+DWPathUtils，均位于GitHub中Tools仓库下。
 GitHub地址：https://github.com/CodeWicky/-Tools
 
 version 1.0.0
 DWStepSlider基本完成
 */

#import "DWSlider.h"

/**
 阶段滑竿
 */
@interface DWStepSlider : DWSlider

///滑块图片
@property (nonatomic ,strong) UIImage * thumbImage;

///滑竿有效值左侧图片
@property (nonatomic ,strong) UIImage * minTrackImage;

///滑竿有效值右侧图片
@property (nonatomic ,strong) UIImage * maxTrackImage;

///滑竿背景图片
@property (nonatomic ,strong) UIImage * trackBgImage;

///滑竿有效值左侧背景颜色
@property (nonatomic ,strong) UIColor * minTrackColor;

///滑竿有效值右侧背景颜色
@property (nonatomic ,strong) UIColor * maxTrackColor;

///节点数组
@property (nonatomic ,strong ,readonly) NSArray * nodes;

///当前节点
@property (nonatomic ,strong) id currentNode;

///初始化方法
-(instancetype)initWithFrame:(CGRect)frame stepNodes:(NSArray *)nodes;

@end
