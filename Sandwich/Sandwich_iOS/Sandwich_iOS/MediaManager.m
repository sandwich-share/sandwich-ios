//
//  MediaManager.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/17/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "MediaManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MediaPlayer.h"

@implementation MediaManager

- (void)startMediaStream:(NSString *)url viewController:(UIViewController *)viewController {
    MediaPlayer* mp = [[MediaPlayer alloc] initWithURL:url viewController:viewController];
    [mp playMedia];
}

- (BOOL)canStreamAsMedia:(NSString *)url {
    //TODO: actually check this
    return TRUE;
}

- (id)init {
    self = [super init];
    [[[AVAudioSession alloc]init] setCategory:AVAudioSessionCategoryAmbient error:nil];
    return self;
}

@end
