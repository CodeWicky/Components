//
//  DWTwinkleItem.m
//  DWTwinkleView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "DWTwinkleItem.h"

@interface DWTwinkleItem ()

@property (nonatomic ,assign) BOOL odd;

@property (nonatomic ,assign) NSUInteger idx;

@end

@implementation DWTwinkleItem

+(instancetype)itemWithIndex:(NSUInteger)index {
    DWTwinkleItem * view = [DWTwinkleItem new];
    view.idx = index;
    if (index % 2) {
        view.image = [UIImage imageNamed:@"red"];
        view.alpha = 0.5;
    } else {
        view.odd = YES;
        view.image = [UIImage imageNamed:@"yellow"];
    }
    NSLog(@"Alloc %ld",view.idx);
    return view;
}

-(void)updateTwinkleWithInfo:(NSDictionary *)userInfo {
    NSUInteger num = [[userInfo valueForKey:@"flag"] unsignedIntegerValue];
//    CGFloat time = [[userInfo valueForKey:@"time"] floatValue];
    if (self.odd ^ (num % 2)) {
        self.alpha = 1;
    } else {
        self.alpha = 0.5;
    }
}

-(void)resetItemStatusOnReLayout {
    
}

-(void)dealloc {
    NSLog(@"Dealloc %ld",self.idx);
}

@end
