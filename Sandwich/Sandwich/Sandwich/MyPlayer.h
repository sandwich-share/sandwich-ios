//
//  MyPlayer.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/15/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"
#import "SearchResult.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MyPlayer : UIViewController
@property SearchResult* file;
@property UIViewController* viewController;
@property NSArray* supportedVideoTypes;

- (MyPlayer*) initWithFile:(SearchResult*)file ViewController:(UIViewController*)viewController;
- (void) startPlaying;

@end
