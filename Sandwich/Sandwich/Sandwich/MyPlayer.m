//
//  MyPlayer.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/15/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "MyPlayer.h"

@implementation MyPlayer

- (MyPlayer*) initWithFile:(SearchResult*)file ViewController:(UIViewController *)viewController{
    self.file = file;
    self.viewController = viewController;
    self.supportedVideoTypes = [NSArray arrayWithObjects:@"mov", @"mp4", @"3gp", @"m4v", nil];
    return [super init];
}

- (void) startPlaying {
    NSString *videoURLString = [[NSString stringWithFormat:@"http://%@:%d/files/%@", self.file.peer.ip, self.file.peer.port, self.file.filepath] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSURL *videoURL = [NSURL URLWithString:videoURLString];
    NSLog(@"VideoURL: %@", videoURLString);
    NSLog(@"Video Format: %@", [videoURL pathExtension]);
    if ([self.supportedVideoTypes containsObject:[videoURL pathExtension]]) {
    
        MPMoviePlayerViewController *moviePlayerView = [[MPMoviePlayerViewController alloc] initWithContentURL:videoURL];
    //NSError* error;
    /*AVAudioSession* audioSession = [AVAudioSession sharedInstance];
     if (![audioSession setCategory:AVAudioSessionCategoryPlayback error:&error]) {
     NSLog(@"AVAudioSession setCategory failed: %@", [error localizedDescription]);
     }
     if (![audioSession setActive:YES error:&error]) {
     NSLog(@"AVAudioSession setActive:YES failed: %@", [error localizedDescription]);
     }
     [moviePlayerView.moviePlayer useApplicationAudioSession];*/
        [self.viewController presentMoviePlayerViewControllerAnimated:moviePlayerView];
    
        [moviePlayerView.moviePlayer play];
    }
    else {
        NSLog(@"Unsupported video format");
    }
}

@end
