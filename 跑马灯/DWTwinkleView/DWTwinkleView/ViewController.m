//
//  ViewController.m
//  DWTwinkleView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWTwinkleView.h"
#import "DWTwinkleItem.h"

@interface ViewController ()

@property (nonatomic ,strong) DWTwinkleView * twinkleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.twinkleView];
    self.twinkleView.backgroundColor = [UIColor lightGrayColor];
    [self.twinkleView startTwinkleWithInterval:0.33];
}

-(DWTwinkleView *)twinkleView {
    if (!_twinkleView) {
        DWTwinkleConfiguration * conf = [DWTwinkleConfiguration new];
        conf.itemSize = CGSizeMake(41, 41);
        conf.margin = -5;
        conf.itemClass = [DWTwinkleItem class];
        conf.spacing = -19;
        _twinkleView = [[DWTwinkleView alloc] initWithFrame:self.view.bounds configuration:conf];
        _twinkleView.userInteractionEnabled = NO;
    }
    return _twinkleView;
}

@end
