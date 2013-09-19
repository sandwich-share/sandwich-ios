//
//  MediaPlayer.m
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/15/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "MediaPlayer.h"
#include <MediaPlayer/MediaPlayer.h>

@implementation MediaPlayer
NSString* URL;
UIViewController* ViewController;

- (id)initWithURL:(NSString *)url viewController:(UIViewController *)viewController {
    self = [super init];
    URL = url;
    ViewController = viewController;
    return self;
}

- (void)playMedia {
    NSURL* streamURL = [[NSURL alloc] initWithString:[URL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
   /* MPMoviePlayerController* mpc = [[MPMoviePlayerController alloc] initWithContentURL:streamURL];
    [mpc play];*/
    
    MPMoviePlayerViewController* mpvc = [[MPMoviePlayerViewController alloc] initWithContentURL:streamURL];
    [[mpvc moviePlayer] setAllowsAirPlay:TRUE];
    [ViewController presentMoviePlayerViewControllerAnimated:mpvc];
    
    
}

@end
