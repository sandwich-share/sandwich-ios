//
//  BootstrapManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "BootstrapManager.h"
#import "Bootstrapper.h"
#import "MainHandler.h"

@implementation BootstrapManager

- (void)performInitialStrap {
    Bootstrapper* bs = [[Bootstrapper alloc] init];
    [bs strapMeToAPeer];
    [bs downloadIndexes];
}

- (void) startUpBootstrapTimer {
    NSLog(@"Starting background timer");
    NSRunLoop* bootstrapRunLoop = [NSRunLoop currentRunLoop];
    
    NSDate* startDate = [NSDate dateWithTimeIntervalSinceNow:5];
    NSTimer* bootstrapTimer = [[NSTimer alloc] initWithFireDate:startDate interval:15 target:self selector:@selector(bgBoostrap:) userInfo:nil repeats:YES];
    [bootstrapRunLoop addTimer:bootstrapTimer forMode:NSDefaultRunLoopMode];
    [bootstrapRunLoop run];
}

- (void) bgBoostrap:(NSTimer*)timer {
    Bootstrapper* bs = [[Bootstrapper alloc]init];
    [[MainHandler getThreadPool] addOperation:bs];
}

@end
