//
//  BootstrapManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/10/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BootstrapManager : NSObject

- (void) performInitialStrap;
- (void) startUpBootstrapTimer;
- (void) bgBoostrap:(NSTimer*)timer;
@end
