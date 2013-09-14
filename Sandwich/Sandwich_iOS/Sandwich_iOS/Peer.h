//
//  Peer.h
//  Sandwich_iOS
//
//  Created by Diego Waxemberg on 8/24/13.
//  Copyright (c) 2013 Diego Waxemberg. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Peer : NSObject

- (Peer*) initWithPeerInfo: (NSString*)ip indexhash:(NSNumber*)indexHash lastSeen:(NSString*)lastSeen;
- (NSString*) getIp;
- (NSNumber*) getIndexHash;
- (NSString*) getLastSeen;

@end
