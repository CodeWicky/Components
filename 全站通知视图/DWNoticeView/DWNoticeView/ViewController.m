//
//  ViewController.m
//  DWNoticeView
//
//  Created by Wicky on 2018/10/9.
//  Copyright © 2018年 Wicky. All rights reserved.
//

#import "ViewController.h"
#import "DWNoticeView.h"
#import "DWHotInHourRankTableViewCell.h"

@interface ViewController ()<DWNoticeViewDelegate>

@property (nonatomic ,strong) DWNoticeView * hourRankBnner;

@property (nonatomic ,strong) NSMutableArray * hourRankArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self configNoticeText];
    [self.view addSubview:self.hourRankBnner];
    [self.hourRankBnner play];
}

-(void)configNoticeText {
    NSMutableArray * tmp  = [NSMutableArray arrayWithCapacity:0];
    [tmp addObject:@"短的1"];
    [tmp addObject:@"这是一条中等长度的2"];
    [tmp addObject:@"我觉得这条应该是一个比较长的文本，这样只有滚动起来才可以看到全部文本3"];
    
    self.hourRankArr = [NSMutableArray arrayWithCapacity:tmp.count];
    for (NSString * txt in tmp) {
        DWHotInHourRankModel * m = [DWHotInHourRankModel new];
        m.text = txt;
        [self.hourRankArr addObject:m];
    }
}

-(UITableViewCell *)banner:(DWNoticeView *)banner cellForRowAtIndex:(NSUInteger)index flag:(BOOL)flag {
    DWHotInHourRankTableViewCell * cell = (DWHotInHourRankTableViewCell *)[banner dequeueCellForID:@"cellID" atIndex:index flag:flag];
    DWHotInHourRankModel * model = [self modelAtIndex:index width:banner.bounds.size.width];
    model.index = index;
    cell.model = model;
    cell.backgroundColor = [UIColor clearColor];
    cell.bannerDidClickCallback = ^(DWHotInHourRankModel *model) {
        NSLog(@"%@",model.text);
    };
    return cell;
}

-(NSUInteger)numberOfRowsForBanner:(DWNoticeView *)banner {
    return self.hourRankArr.count;
}

-(NSTimeInterval)banner:(DWNoticeView *)banner timeIntervalForCellAtIndex:(NSUInteger)index {
    DWHotInHourRankModel * model = [self modelAtIndex:index width:banner.bounds.size.width];
    return model.timeInterval;
}

-(void)banner:(DWNoticeView *)banner didDisplayCell:(UITableViewCell *)cell atIndex:(NSUInteger)index {
    DWHotInHourRankTableViewCell * aCell = (DWHotInHourRankTableViewCell *)cell;
    [self modelAtIndex:index width:banner.bounds.size.width];
    [aCell handleAnimation];
}

-(DWHotInHourRankModel *)modelAtIndex:(NSUInteger)index width:(CGFloat)width {
    DWHotInHourRankModel * model = self.hourRankArr[index];
    [DWHotInHourRankTableViewCell configModelWithCellWidth:width timeInterval:model];
    return model;
}

-(DWNoticeView *)hourRankBnner {
    if (!_hourRankBnner) {
        _hourRankBnner = [[DWNoticeView alloc] initWithFrame:CGRectMake(15, 38 + (15 + 8.5), [UIScreen mainScreen].bounds.size.width - 30, 18) timeInterval:5];
        _hourRankBnner.delegate = self;
        [_hourRankBnner registerClass:[DWHotInHourRankTableViewCell class] forCellReuseIdentifier:@"cellID"];
    }
    return _hourRankBnner;
}



@end
