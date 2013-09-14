//
//  SearchRunner.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 9/7/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Peer.h"
#import <sqlite3.h>

@interface SearchRunner : NSOperation
- (id) initWithPeer:(Peer*)peer searchParams:(NSString*)searchParams;
@end
