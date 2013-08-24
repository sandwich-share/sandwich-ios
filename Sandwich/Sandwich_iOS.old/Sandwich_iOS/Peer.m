//
//  Peer.m
//  Sandwich
//
//  Created by Diego Waxemberg on 4/6/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import "Peer.h"



@implementation Peer

- (Peer*)initWithIP:(NSString*)ip hash:(NSNumber*)hash timestamp:(NSString*)timestamp {
	self.ip = ip;
	self.hash = hash;
	self.timestamp = timestamp;
	return self;
}

@end
