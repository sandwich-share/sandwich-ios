//
//  ConnectionManager.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/25/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"

@interface ConnectionManager : NSObject

- (NSArray*) getPeerList:(Peer*)peer;

@end
