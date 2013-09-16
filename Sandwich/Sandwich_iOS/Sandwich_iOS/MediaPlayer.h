//
//  MediaPlayer.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/15/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

@interface MediaPlayer : NSObject

- (id) initWithURL:(NSString*)url viewController:(UIViewController*)viewController;
- (void) playMedia;

@end
