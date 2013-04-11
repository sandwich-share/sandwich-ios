//
//  Peer.h
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Peer : NSObject
@property NSString* ip;
@property NSNumber* hash;
@property NSString* timestamp;

- (Peer*)initWithIP:(NSString*)ip hash:(NSNumber*)hash timestamp:(NSString*)timestamp;
@end
