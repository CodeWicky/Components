//
//  DWCountdownButton.m
//  DWCountdownButton
//
//  Created by Wicky on 2017/2/4.
//  Copyright © 2017年 Wicky. All rights reserved.
//

#import "DWCountdownButton.h"

@interface DWCountdownButton ()

@property (nonatomic ,assign) CGFloat timeLimit;

@property (nonatomic ,assign) CGFloat timeInterval;

@property (nonatomic ,assign) CGFloat leftTime;

@property (nonatomic ,strong) NSTimer * timer;

@property (nonatomic ,strong) dispatch_semaphore_t semaphonre;

@property (nonatomic ,copy) NSString * originalTitle;

@end

@implementation DWCountdownButton

+(instancetype)buttonWithType:(UIButtonType)buttonType timeLimit:(CGFloat)timeLimit timeInterval:(CGFloat)timeInterval
{
    DWCountdownButton * btn = [super buttonWithType:buttonType];
    if (btn) {
        btn.timeLimit = timeLimit;
        btn.timeInterval = timeInterval;
        btn.semaphonre = dispatch_semaphore_create(1);
        btn.autoDisable = YES;
        [btn setTitleColor:[UIColor blackColor] forState:(UIControlStateNormal)];
    }
    return btn;
}

-(void)startCountdown
{
    if (!self.useAbsoluteTime) {///使用绝对时间
        [self startCountdownWithLeftTime:self.timeLimit timeInterval:self.timeInterval];
    } else {
        NSInteger lastTime = [self loadTimeWithKey:self.absoluteTimeKey];
        NSInteger timeStamp = [[NSDate date] timeIntervalSince1970];
        if (timeStamp - lastTime >= self.timeLimit) {///超过时间
            [self startCountdownWithLeftTime:self.timeLimit timeInterval:self.timeInterval];
        }
        else
        {
            CGFloat leftTime = self.timeLimit - (timeStamp - lastTime);
            [self startCountdownWithLeftTime:leftTime timeInterval:self.timeInterval];
        }
        [self saveTime:timeStamp withKey:self.absoluteTimeKey];
    }
}

-(void)suspendCountdown
{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantFuture]];
    }
}

-(void)resumeCountdown
{
    if (self.timer) {
        [self.timer setFireDate:[NSDate distantPast]];
    }
    else
    {
        [self startCountdown];
    }
}

-(void)stopCountdown
{
    [self invalidateTimer];
    [self setTitleStr:self.timeOutTitle];
}

-(void)startCountdownWithLeftTime:(CGFloat)leftTime timeInterval:(CGFloat)timeInterval
{
    if (!self.timer) {
        self.originalTitle = self.titleLabel.text;
    }
    [self invalidateTimer];
    self.leftTime = leftTime;
    [self setTitleStr:[NSString stringWithFormat:self.titleFormatter,self.leftTime]];
    self.timer = [NSTimer timerWithTimeInterval:timeInterval target:self selector:@selector(timerAction:) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
    if (self.autoDisable) {
        self.enabled = NO;
    }
}

-(void)timerAction:(NSTimer *)timer
{
    dispatch_semaphore_wait(self.semaphonre, DISPATCH_TIME_FOREVER);
    self.leftTime -= self.timeInterval;
    if (self.leftTime > 0) {
        NSString * title = [NSString stringWithFormat:self.titleFormatter,self.leftTime];
        [self setTitleStr:title];
    }
    else
    {
        [self invalidateTimer];
        [self setTitleStr:self.timeOutTitle];
        if (self.autoDisable) {
            self.enabled = YES;
        }
        if (self.timeOutBlock) {
            __weak typeof(self)weakSelf = self;
            self.timeOutBlock(weakSelf);
        }
    }
    dispatch_semaphore_signal(self.semaphonre);
}

-(void)setTitleStr:(NSString *)title
{
    [self setTitle:title forState:(UIControlStateNormal)];
}

-(void)invalidateTimer
{
    if (self.timer) {
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(NSString *)userArchivePath
{
    NSString *dicPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *strPath = [dicPath stringByAppendingString:@"/DWCountdownButtonTime"];
    return strPath;
}

-(void)saveTime:(NSInteger)time withKey:(NSString *)key
{
    NSMutableDictionary * dic = [self fetchLocalDic];
    [dic setValue:@(time) forKey:key];
    [NSKeyedArchiver archiveRootObject:dic toFile:[self userArchivePath]];
}

-(NSInteger)loadTimeWithKey:(NSString *)key
{
    NSMutableDictionary * dic = [self fetchLocalDic];
    return [dic[key] integerValue];
}

-(NSMutableDictionary *)fetchLocalDic
{
    NSMutableDictionary * dic = [NSKeyedUnarchiver unarchiveObjectWithFile:[self userArchivePath]];
    if (!dic) {
        dic = [NSMutableDictionary dictionary];
        [NSKeyedArchiver archiveRootObject:dic toFile:[self userArchivePath]];
    }
    return dic;
}

-(NSString *)titleFormatter
{
    if (!_titleFormatter) {
        return @"(%.0f秒)";
    }
    return _titleFormatter;
}

-(NSString *)timeOutTitle
{
    if (!_timeOutTitle) {
        if (self.originalTitle) {
            return self.originalTitle;
        }
        return @"重新计时";
    }
    return _timeOutTitle;
}

-(NSString *)absoluteTimeKey
{
    if (!_absoluteTimeKey) {
        return @"defaultKey";
    }
    return _absoluteTimeKey;
}

@end
