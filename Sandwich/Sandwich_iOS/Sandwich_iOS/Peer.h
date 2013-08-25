//
//  Peer.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Peer : NSObject

- (Peer*) initWithPeerInfo: (NSString*)ip indexhash:(NSString*)indexHash lastSeen:(NSString*)lastSeen;

@end
