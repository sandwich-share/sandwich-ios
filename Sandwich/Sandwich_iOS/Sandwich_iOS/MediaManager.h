//
//  MediaManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/17/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MediaManager : NSObject

- (BOOL) canStreamAsMedia:(NSString*)url;
- (void) startMediaStream:(NSString*)url viewController:(UIViewController*)viewController;

@end
